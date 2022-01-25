# Memcached Server made with Ruby.

Memcached server (TCP/IP socket) that complies with the specified protocol.

## About Ruby: 
Ruby is a programing lenguaje orientated to "objects", inspired in Python and Pearl.
https://www.ruby-lang.org/

## About Memcached:
Memcached is a simply storage system that improve the App performance.
https://memcached.org/

## Dependencies:
RSPEC: 3.10
https://rubygems.org/gems/rspec/versions/3.5.0?locale=es

## How to run:
### Server:
In your terminal, type: ruby memcached-server.rb <hostname> <port>
### Client:
In your terminal, type: ruby memcached-server.rb <hostname> <port>

## Using Memcached:
The Client sends certain commands:

### set: Set a key unconditionally
<command > <key> <flags> <exptime> <bytes> [noreply]

### add: Add a new key
<command > <key> <flags> <exptime> <bytes> [noreply]

### replace: Overwrite existing key
<command > <key> <flags> <exptime> <bytes> [noreply]

### append: Append data to existing key
<command > <key> <flags> <exptime>  <bytes> [noreply]

### prepend: Prepend data to existing key
<command > <key> <flags> <exptime>  <bytes> [noreply]

### cas: check and set / check and swap the data if it is not updated since last fetch.
<command > <key> <flags> <exptime>  <bytes> <casToken> [noreply]

## Uses of:

### <key>: the client define it and under wich asks to store the data.

### <flags>: is a 4byte space that is stored alongside of the main value.

### <exptime>: is expiration time. If it's 0, the item never expires.

### <bytes>: is the number of bytes in the input.

### <casToken>: it's a unique integer value came from an existing key.

### <noreply>: it's an optional parameter that intructs to the server to no send the reply.

### <input>: it's a chunk of arbitrary 8-bit data