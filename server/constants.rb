module MemcachedServer

    module Commands


        #Comandos de almacenamiento segun Memcached.
        #\w espera una palabra
        #\d espera una numero
        # REGular  EXpression (REGEX)
        SET = /^(?<name>set) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        ADD = /^(?<name>add) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        REPLACE = /^(?<name>replace) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        APPEND = /^(?<name>append) (?<key>(\w)+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        PREPEND = /^(?<name>prepend) (?<key>(\w)+) (?<bytes>\d+)(?<noreply>noreply)?\n/.freeze
        CAS = /^(?<name>cas) (?<key>(\w)+) (?<flags>\d+) (?<exptime>\d+) (?<bytes>\d+) (?<casToken>\d+)(?<noreply>noreply)?\n/.freeze
        
        #Comandos para pedir informacion al servidor.
        GET = /^(?<name>get) (?<keys>(\w|\p{Space})+)\n/.freeze
        GETS = /^(?<name>gets) (?<keys>(\w|\p{Space})+)\n/.freeze
        #Cierre
        #El gion bajo es por el uso de la palabra reservada END
        END_ = /^(?<name>END)\n$/.freeze
    end

    module ServerReply

        # Almacenamiento exitoso.
        STORED = "STORED\n".freeze

        #No se logro almacenar con exito.
        NOT_STORED = "NOT_STORED\n".freeze
        
        #Indica que el item que queremos almacenar con CAS ha sido modificado previamente.
        EXISTS = "EXISTS\n".freeze

        #El item que queremos almacenar con CAS no existe.
        NOT_FOUND = "NOT_FOUND\n".freeze

        # Informacion que nos devuelve el servidor ordenado segun Memcached.
        GET = "VALUE %s %d %d\n%s\n".freeze
        GETS = "VALUE %s %d %d %d\n%s\n".freeze
        
        END_ = "END\n".freeze

    end

    module ReplyFormat

        # Formato en que el servidor devuelve los items
        GET = /VALUE (?<key>\w+) (?<flags>\d+) (?<bytes>\d+)/.freeze
        GETS = /VALUE (?<key>\w+) (?<flags>\d+) (?<bytes>\d+) (?<casToken>\d+)/.freeze

        #Final de un proceso.
        END_ = /END/.freeze
        
    end

    module Fail
        #Fallas en comandos, cliente o servidor.
        ERROR = "ERROR\r\n".freeze
        CLIENT_ERROR = "CLIENT_ERROR%s\r\n".freeze
        SERVER_ERROR = "SERVER_ERROR%s\r\n".freeze
        
    end

end