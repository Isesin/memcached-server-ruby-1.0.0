require 'socket'
require_relative 'constants.rb'

module MemcachedServer
  
  #Clase que define el cliente que se conecta al Servidor
  class Client

    attr_reader :host
    attr_reader :port

    def initialize(host, port)
        @host = host
        @port = port
        @server = TCPSocket.new(host, port)
    end

    #Formato de comando SET.
    def set(key, flags, exptime, bytes, input)
      command = "set #{key} #{flags} #{exptime} #{bytes}\n#{input}\n"
      @server.puts(command)

      return @server.gets()
    end

    #Formato de comando ADD.
    def add(key, flags, exptime, bytes, input)
      command = "add #{key} #{flags} #{exptime} #{bytes}\n#{input}\n"
      @server.puts(command)

      return @server.gets()
    end


    #Formato de comando REPLACE.
    def replace(key, flags, exptime, bytes, input)
      command = "replace #{key} #{flags} #{exptime} #{bytes}\n#{input}\n"
      @server.puts(command)

      return @server.gets()
    end

    #Formato de comando APPEND.
    def append(key, bytes, input)
      command = "append #{key} #{bytes}\n#{input}\n"
      @server.puts(command)
      return @server.gets()
    end

   #Formato de comando PREPEND.
    def prepend(key, bytes, input)
      command = "prepend #{key} #{bytes}\n#{input}\n"
      @server.puts(command)
      return @server.gets()
    end

   #Formato de comando CAS.
    def cas(key, flags, exptime, bytes, casToken, input)
      command = "cas #{key} #{flags} #{exptime} #{bytes} #{casToken}\n#{input}\n"
      @server.puts(command)

      return @server.gets()
    end

   #Formato de comando GET.
    def get(keys)
      @server.puts("get #{keys}")

      n = keys.split(' ').length()
      retrieved = {}
      n.times do
        loop do
          case @server.gets()
          when ReplyFormat::GET
            key = $~[:key]
            flags = $~[:flags].to_i()
            bytes = $~[:bytes].to_i()
            input = @server.read(bytes + 1).chomp()

            item = Item.new(key, flags, 0, bytes, input)
            retrieved[key.to_sym] = item

          when ReplyFormat::END_
            break
          else
            puts "Error\nServer: #{$_}"
            break
          end
        end
      end
      return retrieved
    end
     
  #Formato de comando GETS.
    def gets(keys)
      @server.puts("gets #{keys}")

      n = keys.split(' ').length()
      retrieved = {}

      n.times do

        loop do

          case @server.gets()
          when ReplyFormat::GETS
            key = $~[:key]
            flags = $~[:flags].to_i()
            bytes = $~[:bytes].to_i()
            casToken = $~[:casToken].to_i()
            input = @server.read(bytes + 1).chomp()

            item = Item.new(key, flags, 0, bytes, input)
            item.casToken = casToken
            retrieved[key.to_sym] = item

          when ReplyFormat::END_
            break

          else
            puts "Error\nServer: #{$_}"
            break

          end

        end

      end

      return retrieved
    end

    #Enviar un END.
    def end()
      @server.puts('END')
      return @server.gets()
    end

  end

end
