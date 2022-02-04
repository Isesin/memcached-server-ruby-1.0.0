require_relative './constants.rb'
class Client
  attr_reader :host
  attr_reader :port

    def initialize(host, port)   
      @host = host
      @port = port  

        socket = TCPSocket.new(host, port)

        readerThread = Thread.new {
            while line = socket.gets()
              puts(line)
            end
          }
          
          writerThread = Thread.new { 
            loop do
                command = STDIN.gets()
                socket.puts(command)
                break if $_.match(ServerReplies::CONNECTION_END)
                sleep(0.1)
            end
          }
          
          readerThread.join()
          writerThread.join()
          
          socket.close()
    end
    
end