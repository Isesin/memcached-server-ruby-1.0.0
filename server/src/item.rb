

    #DEFINIENDO VALORES SEGUN USOS DE MEMCACHED
    class Item
        attr_accessor :key
        attr_accessor :flags
        attr_accessor :exptime
        attr_accessor :bytes
        attr_accessor :input    
        attr_accessor :casToken
          
        attr_accessor :lock
        #ESTABLECIENDO EL TOKEN 0
        @@lastcasToken = 0

        #Metodo constructor
        def initialize(key,flags, exptime,bytes,input)
            @key = key
            @flags = flags
            @exptime = get_exptime(exptime)
            @bytes = bytes
            @input = input
            #aplicando un "semaforo" para edicion de datos.
            @lock = Mutex.new()
        end

        #aumento de cas Token segun Memcached
        def get_casToken()
            @lock.synchronize do
                @@lastcasToken +=1
                nextToken = @@lastcasToken.dup()

                return nextToken
            end
        end

        #actualizacion de cas Token tomado del ultimo valor.
        def update_casToken ()
            @casToken = get_casToken()
        end

        #Revision de los parametros de EXP TIME
        def get_exptime (exptime)
            return nil if exptime == 0
            return Time.now().getutc() if exptime < 0
            return Time.now().getutc() + exptime            
        end

        #Verifacion de EXP TIME
        def expired?()
            return true if (!exptime.nil?()) && (Time.now().getutc() > exptime)
            return false
        end
    end
