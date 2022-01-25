# Memcached Server made with Ruby.

Memcached server (TCP/IP socket) that complies with the specified protocol.

## About Ruby: 
Ruby is a programing lenguaje orientated to "objects", inspired in Python and Pearl.
https://www.ruby-lang.org/

## About Memcached:
Memcached is a simply storage system that improve the App performance.
https://memcached.org/

## Dependencies:
Need to install
### Ruby: 3.0.3
https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.3.tar.gz

### RSPEC: 3.10
https://rubygems.org/gems/rspec/versions/3.10.0

## To run all tests:
In your terminal, type: rspec

## How to run:
### Server:
In your terminal, type: ruby memcached-server.rb <"hostname / IP"> <"port">
Example: ruby memcached-server.rb localhost 123456
### Client:
In your terminal, type: ruby memcached-client.rb <"hostname / IP"> <"port">
Example: ruby memcached-client.rb localhost 123456
## Using Memcached:
The Client sends certain commands:

### set:
store this data, possibly overwriting any existing data.
```<<command > <key> <flags> <exptime> <bytes> [noreply]```

### add: 
store this data, only if it does not already exist.
```<<command > <key> <flags> <exptime> <bytes> [noreply]```

### replace: 
store this data, but only if the data already exists. Almost never used, and exists for protocol completeness (set, add, replace, etc)
```<<command > <key> <flags> <exptime> <bytes> [noreply]```

### append: 
add this data after the last byte in an existing item. This does not allow you to extend past the item limit. Useful for managing lists.
```<<command > <key> <flags> <exptime> <bytes> [noreply]```

### prepend: 
same as append, but adding new data before existing data.
```<<command > <key> <flags> <exptime> <bytes> [noreply]```

### cas: 
check And Set (or Compare And Swap). An operation that stores data, but only if no one else has updated the data since you read it last. Useful for resolving race conditions on updating cache data.
```<<command > <key> <flags> <exptime> <bytes> <casToken> [noreply]```

## Uses of:

### key: 
the client define it and under wich asks to store the data.

### flags: 
it's a 4byte space that is stored alongside of the main value.

### exptime: 
it's expiration time. If it's 0, the item never expires.

### bytes: 
it's the number of bytes in the input.

### casToken: 
it's a unique integer value came from an existing key.

### noreply: 
it's an optional parameter that intructs to the server to no send the reply.

### input: 
it's a chunk of arbitrary 8-bit data of length form bytes.

## Server Replies:

### STORED: 
to indicate success.

### NOT_STORED: 
the data wasn't stored.

### EXISTS: 
indicate the item you are trying to store with CAS has been modified since you last fetched it.

### NOT_FOUND: 
the item your are trying to store witch a CAS did not exist.

## GETTING DATA:

### get: 
command for retrieving data. Takes one or more keys and returns all found items.

### gets: 
an alternative get command for using with CAS. Returns a CAS identifier (a unique 64bit number) with the item. Return this value with the cas command. If the item's CAS value has changed since you gets'ed it, it will not be stored.

## END COMMAND:

### END: 
to end the session, use: END