require_relative '../../server/memcached-server.rb'
include MemcachedServer

RSpec.describe Memcached do

    before(:each) do 

        @memcache = Memcached.new()
        @storage = @memcache.storage

        @item_a = Item.new("a", 0, 0, 5, "val_a")

    end
    #Ejecutamos el metodo purgeKeys establecido en memcache.rb
    describe "#purgeKeys" do
             
        context "when success" do
            #Creamo dos objetos (expired_item y item_to-espire) con una funcion con valores indistintos para probar el metodo.
            let(:expired_item)   { Item.new("key", 0, -1, 3, "val") }
            let(:item_to_expire) { Item.new("kee", 0, 0.1, 3, "val") }
            before(:each) do 
                @storage.store(:key, expired_item)
                @storage.store(:kee, item_to_expire)
        
                sleep(0.1)
                @memcache.purgeKeys()
            end
            
            it "purges expired keys in storage" do
                expect(@storage).to be_empty
            end
        end
    end
    
    describe "#cas" do
        #Elevamos el casToken utulizando los metodos update/get
        #establecidos en memcache.rb:28 :38
        before(:each) do
            @item_a.update_casToken()
            @storage.store("a", @item_a)
        end
        #Creamos el objeto "reply_stored"
        #utilizamos la funcion cas de memcache.rb
        context "when success" do
            let(:reply_stored) { @memcache.cas("a", 0, 0, 3, 1, "val") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end
        #Creamos 2 objetos con 2 posibles fallas.
        context "when failure" do
            let(:reply_exists)    { @memcache.cas("a", 0, 0, 3, 4, "val") }
            let(:reply_not_found) { @memcache.cas("b", 0, 0, 3, 1, "val") }

            it "responds with EXISTS" do
                expect(reply_exists).to eq ServerReply::EXISTS                
            end

            it "responds with NOT_FOUND" do
                expect(reply_not_found).to eq ServerReply::NOT_FOUND 
            end
        end
    end

    describe "#get" do

        context "when success" do
            #Creamos 2 objetos con funcion.
            
            let(:item_b) { Item.new("b", 0, 0, 5, "val_b") }
            let(:item_c) { Item.new("c", 0, 0, 5, "val_c") }

            #objeto tipo respuesta 
            #es una objeto con una funcion dentro
            #"trae" los 3 objetos utilizando la funcion get de memcache.rb
            let(:empty)       { @memcache.get([]) }
            let(:one_item)    { @memcache.get([:a]) }
            let(:three_items) { @memcache.get([:a, :b, :c]) }

            
            before(:each) do
            #Almacena los objetos anteriores.  
                @storage.store(:a, @item_a)
                @storage.store(:b, item_b)
                @storage.store(:c, item_c)
                end
            
            #el expect ejecuta la funcion empty.
            it "retrieves zero items" do
                expect(empty).to be_empty
            end
            #el expect ejecuta la funcion one item
            it "retrieves one item" do
                expect(one_item).to eq [@item_a]
            end
            #el expect ejecuta la funcion trhee items
            it "retrieves three items" do
                expect(three_items).to eq [@item_a, item_b, item_c]
            end
        end

        context "when failure" do
            #es una objeto con una funcion dentro
            let(:nil_items) { @memcache.get([:x, :y, :z]) }
            #el expect ejecita el nill y nos devuelve nil.
            it "returns an array with nil values" do
                expect(nil_items).to eq [nil, nil, nil]
            end
        end
    end

    describe "#set" do

        context "when success" do
            #Establece un objeto con una funcion con valores correctos.
            #usamos la funcion set de memcache.rb
            let(:reply_stored) { @memcache.set("a", 0, 0, 5, "val_a") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end
    end


    describe "#add" do
        #Almacenamos un objeto con la key "a"
        before(:each) do
            @storage.store("a", @item_a)
        end
        #Agregamos un objeto con una funcion la key "b"
        #usamos la funcion add de memcache.rb
        context "when success" do
            let(:reply_stored) { @memcache.add("b", 0, 0, 3, "val") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end

        context "when failure" do
            #Al crear un objeto con la key "a" no se almacena
            #porque ya almacenamos un objeto con la key "a" en el before.
            let(:reply_not_stored) { @memcache.add("a", 0, 0, 3, "val") }

            it "responds with NOT_STORED" do
                expect(reply_not_stored).to eq ServerReply::NOT_STORED
            end
        end
    end

    describe "#replace" do
        #Almacena un objeto con la key "a"
        before(:each) do
            @storage.store("a", @item_a)
        end

        context "when success" do
            #Crea un objeto utilizando la funcion replace con la key "a"
            let(:reply_stored) { @memcache.replace("a", 0, 0, 3, "val") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end
        
        context "when failure" do
            #Crea un objeto utilizando la funcion replace con la key "b"
            #falla pues en el before usamos storage con un item de key "a"
            let(:reply_not_stored) { @memcache.replace("b", 0, 0, 3, "val") }

            it "responds with NOT_STORED" do
                expect(reply_not_stored).to eq ServerReply::NOT_STORED
            end
        end
    end

    describe "#append" do
        #almacenamos un item_a con la key "a"
        before(:each) do
            @storage.store("a", @item_a)
        end

        context "when success" do
            #Creamos un objeto con la funcion append sobre el anterior con key "a".
            let(:reply_stored) { @memcache.append("a", 4, "_new") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end

        context "when failure" do
            #Creamos un objeto con la funcion append sobre el anterior con key "b"
            #Falla por la key erronea.
            let(:reply_not_stored) { @memcache.append("b", 3, "val") }

            it "responds with NOT_STORED" do
                expect(reply_not_stored).to eq ServerReply::NOT_STORED
            end
        end
    end

    describe "#prepend" do
        #almacenamos un item_a con la key "a"
        before(:each) do
            @storage.store("a", @item_a)
        end

        context "when success" do
            #Creamos un objeto con la funcion prepend sobre el anterior con key "a".
            let(:reply_stored) { @memcache.prepend("a", 4, "new_") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end

        context "when failure" do
            #Creamos un objeto con la funcion append sobre el anterior con key "b"
            #Falla por la key erronea.
            let(:reply_not_stored) { @memcache.prepend("b", 3, "val") }

            it "responds with NOT_STORED" do
                expect(reply_not_stored).to eq ServerReply::NOT_STORED
            end
        end
    end

    describe "#storeItem" do

        context "when success" do
            #Almacenamos 2 objetos con keys "a" y "b"
            before(:each) do
                @memcache.storeItem("a", 0, 600, 3, "val")
                @memcache.storeItem("b", 0, 0, 3, "val")
            end

            it "stores two items" do
                expect(@storage.keys).to eq ["a", "b"]
            end
        end

        context "when failure" do
            before(:each) do
                #almacenamos objeto con key "c" y exptime incorrecto.
                #no almacena.
                @memcache.storeItem("c", 0, -1, 3, "val")
            end

            it "does not store the expired item" do
                expect(@storage["c"]).to be nil
            end
        end
    end
    
end
