require_relative './item.rb'
require_relative './constants.rb'

module MemcachedServer

    # The class used to process Memcache commands and store the Memcache server data
    class Memcached


        #Definimos una clase Memcached con un un HASH.
        attr_reader :storage

        def initialize()
            @storage = Hash.new()
        end


        #Definimos como borrar items expirados
        def purgeKeys()
            @storage.delete_if { | key, item | item.expired? }
        end


        #Definimos el GET y ejecutamos el purgekeys dentro.
        def get(keys)
            purgeKeys()
            items = @storage.values_at(*keys)
            return items
        end


        #Definimos el metodo de almacenamiento
        #Antes de agregar el item, se le asigna el CAS id
        def storeItem(key, flags, exptime, bytes, input)
            item = Item.new(key, flags, exptime, bytes, input)
            item.update_casToken()
            item.lock.synchronize do                
                @storage.store(key, item) unless item.expired?()
            end

        end


        #Definimos los parametros del SET y ejecutamos el metodo storeItem
        def set(key, flags, exptime, bytes, data_block)
            storeItem(key, flags, exptime, bytes, data_block)
            return ServerReply::STORED
        end

        #Definimos los parametros del ADD y ejecutamos el metodo storeItem
        def add(key, flags, exptime, bytes, input)
            purgeKeys()            
            return ServerReply::NOT_STORED if @storage.key?(key)
            storeItem(key, flags, exptime, bytes, input)
            return ServerReply::STORED
        end

        #Definimos los parametros del REPLACE y ejecutamos el metodo storeItem
        def replace(key, flags, exptime, bytes, input)            
            return ServerReply::NOT_STORED unless @storage.key?(key)
            storeItem(key, flags, exptime, bytes, input)
            return ServerReply::STORED
        end
        
        #Definimos los parametros del APPEND y ejecutamos el metodo storeItem
        def append(key, bytes, newInput)
            purgeKeys()
            return ServerReply::NOT_STORED unless @storage.key?(key)
            item = @storage[key]
            item.lock.synchronize do
                item.input.concat(newInput)
                item.bytes += bytes
            end
            item.update_casToken()
            return ServerReply::STORED

        end


        #Definimos los parametros del PREPEND y ejecutamos el metodo storeItem
        def prepend(key, bytes, newInput)
            purgeKeys()
            return ServerReply::NOT_STORED unless @storage.key?(key)

            item = @storage[key]
            item.lock.synchronize do 
                item.input.prepend(newInput)
                item.bytes += bytes
            end
            item.update_casToken()
            return ServerReply::STORED
        end


        #Definimos los parametros del CAS y ejecutamos el metodo storeItem
        def cas(key, flags, exptime, bytes, casToken, input)
            purgeKeys()
            return ServerReply::NOT_FOUND unless @storage.key?(key)
            item = @storage[key]
            item.lock.synchronize do
                return ServerReply::EXISTS if casToken != item.casToken
            end
            storeItem(key, flags, exptime, bytes, input)
            return ServerReply::STORED
        end
    end

end
