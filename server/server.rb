require 'socket'
require_relative './memcache.rb'
require_relative './constants.rb'

module MemcachedServer
    
    #Implementamos un servidor Memcached
    class Server
        #Presentamos los parametros de un servidor TCP
        attr_reader :host
        attr_reader :port
        #Presentamos los parametros de Memcached.
        attr_reader :mc

        #Establecemos el servidor y Memcached.
        def initialize(host, port)
            @host = host
            @port = port
            @connection = TCPServer.new(host, port)
            @mc = Memcached.new()            
        end

        # Iniciamos el sevidor
        def run()
            
            begin
                loop do
                    Thread.start(@connection.accept()) do | connection |

                        puts("New connection: #{connection.to_s}.")

                        close = false
                        while command = connection.gets()

                            puts("Command: #{command} | Connection: #{connection.to_s}")

                            validCommand = validateCommand(command)
                            if validCommand
                                close = run_command(connection, validCommand)
                            else
                                connection.puts(Fail::ERROR)
                            end

                            break if close

                        end

                        connection.puts(ServerReply::END_)
                        connection.close()
                        puts ("Connection closed to: #{connection}.")

                    end
                end
                
            rescue => exception
                error = Fails::SERVER_ERROR % exception.message
                connection.puts(error)
            end
        end

        #Ejecutamos un comando valido de Memcached establecido en memcache.rb
        def run_command(connection, validCommand)
            #puts ("shrek:  #{validCommand}.")
            name = validCommand[:name]

            case name
            when 'set', 'add', 'replace'

                key = validCommand[:key]
                flags = validCommand[:flags].to_i
                exptime = validCommand[:exptime].to_i
                bytes = validCommand[:bytes].to_i
                noreply = !validCommand[:noreply].nil?
                data = self.read_bytes(connection, bytes)

                reply = @mc.send(name.to_sym, key, flags, exptime, bytes, data) unless data.nil?()
                connection.puts(reply) unless noreply || reply.nil?()

                return false

            when 'append', 'prepend'

                key = validCommand[:key]
                bytes = validCommand[:bytes].to_i
                data = self.read_bytes(connection, bytes)

                reply = @mc.send(name.to_sym, key, bytes, data) unless data.nil?()
                connection.puts(reply) unless noreply || reply.nil?()

                return false

            when 'cas'

                key = validCommand[:key]
                flags = validCommand[:flags].to_i
                exptime = validCommand[:exptime].to_i
                bytes = validCommand[:bytes].to_i
                noreply = !validCommand[:noreply].nil?
                data = self.read_bytes(connection, bytes)
                casToken = validCommand[:casToken].to_i()

                reply = @mc.cas(key, flags, exptime, bytes, casToken, data) unless data.nil?()
                connection.puts(reply) unless noreply || reply.nil?()

                return false
                
            when 'get'

                keys = validCommand[:keys].split(' ')
                items = @mc.get(keys)

                for item in items
                    connection.puts(ServerReply::GET % [item.key, item.flags, item.bytes, item.input]) if item
                    connection.puts(ServerReply::END_)
                end

                return false

            when 'gets'

                keys = validCommand[:keys].split(' ')
                items = @mc.get(keys)
                #puts ("shrek:  #{items}.")

                for item in items
                    connection.puts(ServerReply::GETS % [item.key, item.flags, item.bytes, item.casToken, item.input]) if item
                    connection.puts(ServerReply::END_)
                end

                return false

            else
                #End deja de correr el cliente.
                return true
                
            end
        end
        

        #Leemos los bytes para corroborar cuando se carga un item
        def read_bytes(connection, bytes)

            data_chunk = connection.read(bytes + 1).chomp()

            if data_chunk.bytesize() != bytes
                connection.puts(Fail::CLIENT_ERROR % [" bad data chunk"])
                return nil
            end

            return data_chunk
        end

        #Validando el comando ingresado, si es incorrecto, nos devuelve nil (nada).
        def validateCommand(command)

            valid_formats = Commands.constants.map{| key | Commands.const_get(key)}

            valid_formats.each do | form |

                validCommand = command.match(form)
                return validCommand unless validCommand.nil?
                
            end

            return nil
        end

        #Aceptra conexiones de un TCP SOCKET
        def accept()
            return @connection.accept()
        end

    end

end
