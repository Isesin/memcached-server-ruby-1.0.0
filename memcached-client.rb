
require 'socket'
require_relative './server/memcached-server.rb'

host = ARGV[0]
port = ARGV[1]

socket = TCPSocket.new(host, port)


listener = Thread.new {
  while line = socket.gets()
    puts(line)
  end
}

speaker = Thread.new {
  loop do
      command = STDIN.gets()
      socket.puts(command)
      break if $_.match(MemcachedServer::ServerReply::END_)
      sleep(0.1)
  end
}

listener.join()
speaker.join()

socket.close()