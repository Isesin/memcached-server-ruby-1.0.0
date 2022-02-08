require_relative './src/server.rb'

host = ARGV[0]
port = ARGV[1]

server = MemcachedServer::Server.new(host, port)
puts ('Server running on port %d' % server.port)
  
server.run()
