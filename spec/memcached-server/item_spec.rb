require_relative '../../server/src/item.rb'

RSpec.describe Item do
    #El test utiliza el metodo expired? establecido en item.rb
    describe "#expired?" do

        context "when expired" do
            #Creamos un objeto "x" con una funcion con valores indistintos para probar el metodo.
            let(:expired_item) { Item.new("a", 0, -1, 5, "value") }

            it "returns true" do
                expect(expired_item.expired?).to be true
            end
        end

        context "when not expired" do
            #Creamos un objeto "x" con una funcion con valores indistintos para probar el metodo.
            let(:not_expired_item) { Item.new("a", 0, 600, 5, "value") }

            it "returns false" do
                expect(not_expired_item.expired?).to be false

            end
            
        end
  
        context "when never expires" do
            #Creamos un objeto "x" con una funcion con valores indistintos para probar el metodo.
            let(:never_expired_item) { Item.new("b", 0, 0, 5, "value") }

            it "returns false" do
                expect(never_expired_item.expired?).to be false
            end
        end
        
    end
    
end
