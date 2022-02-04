require 'socket'
require_relative './src/client.rb'

host = ARGV[0]
port = ARGV[1]

client = Client.new(host, port)
