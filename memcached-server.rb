require_relative './server/item.rb' #Detalle de la data que ingresaremos al servidor.
require_relative './server/constants.rb' #Implementamos los comandos de Memcached.
require_relative './server/memcache.rb' #Implementamos el funcionamiento Memcached.
require_relative './server/server.rb' #Implementa un servidor TCP con Memcached
require_relative './server/client.rb' #Clase que define los parametros del cliente Socket.