require_relative './item.rb' #Detalle de la data que ingresaremos al servidor.
require_relative './constants.rb' #Implementamos los comandos de Memcached.
require_relative './memcache.rb' #Implementamos el funcionamiento Memcached.
require_relative './server.rb' #Implementa un servidor TCP con Memcached
require_relative './client.rb' #Clase que define los parametros del cliente Socket.