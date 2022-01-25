require_relative '../../server/memcached-server.rb'
include MemcachedServer

RSpec.describe Memcached do

    before(:each) do 

        @memcache = Memcached.new()
        @storage = @memcache.storage

        @item_a = Item.new("a", 0, 0, 5, "val_a")

    end

    describe "#purgeKeys" do
             
        context "when success" do
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

        before(:each) do
            @item_a.update_casToken()
            @storage.store("a", @item_a)
        end

        context "when success" do
            let(:reply_stored) { @memcache.cas("a", 0, 0, 3, 1, "val") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end
        
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
             #puts "b"
            #objeto tipo item
            let(:item_b) { Item.new("b", 0, 0, 5, "val_b") }
            let(:item_c) { Item.new("c", 0, 0, 5, "val_c") }

            #objeto tipo respuesta 
            #es una objeto con una funcion dentro
            let(:empty)       { @memcache.get([]) }
            let(:one_item)    { @memcache.get([:a]) }
            let(:three_items) { @memcache.get([:a, :b, :c]) }

            
            before(:each) do
               # puts "a"
                @storage.store(:a, @item_a)
                @storage.store(:b, item_b)
                @storage.store(:c, item_c)
                #puts("New connection: #{three_items}.")
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
            let(:reply_stored) { @memcache.set("a", 0, 0, 5, "val_a") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end
    end

    describe "#add" do

        before(:each) do
            @storage.store("a", @item_a)
        end

        context "when success" do
            let(:reply_stored) { @memcache.add("b", 0, 0, 3, "val") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end

        context "when failure" do
            let(:reply_not_stored) { @memcache.add("a", 0, 0, 3, "val") }

            it "responds with NOT_STORED" do
                expect(reply_not_stored).to eq ServerReply::NOT_STORED
            end
        end
    end

    describe "#replace" do

        before(:each) do
            @storage.store("a", @item_a)
        end

        context "when success" do
            let(:reply_stored) { @memcache.replace("a", 0, 0, 3, "val") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end
        
        context "when failure" do
            let(:reply_not_stored) { @memcache.replace("b", 0, 0, 3, "val") }

            it "responds with NOT_STORED" do
                expect(reply_not_stored).to eq ServerReply::NOT_STORED
            end
        end
    end

    describe "#append" do

        before(:each) do
            @storage.store("a", @item_a)
        end

        context "when success" do
            let(:reply_stored) { @memcache.append("a", 4, "_new") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end

        context "when failure" do
            let(:reply_not_stored) { @memcache.append("b", 3, "val") }

            it "responds with NOT_STORED" do
                expect(reply_not_stored).to eq ServerReply::NOT_STORED
            end
        end
    end

    describe "#prepend" do

        before(:each) do
            @storage.store("a", @item_a)
        end

        context "when success" do
            let(:reply_stored) { @memcache.prepend("a", 4, "new_") }

            it "responds with STORED" do
                expect(reply_stored).to eq ServerReply::STORED
            end
        end

        context "when failure" do
            let(:reply_not_stored) { @memcache.prepend("b", 3, "val") }

            it "responds with NOT_STORED" do
                expect(reply_not_stored).to eq ServerReply::NOT_STORED
            end
        end
    end

    describe "#storeItem" do

        context "when success" do
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
                @memcache.storeItem("c", 0, -1, 3, "val")
            end

            it "does not store the expired item" do
                expect(@storage["c"]).to be nil
            end
        end
    end
    
end
