require_relative '../lib/wallet_central'

RSpec.describe "WalletCentral" do
 

  describe "when wallets are filterd by client" do

    context "with an existing client" do
    
      it "shows only client's wallets" do
        expected_response = {"EUR"=>"868.65", "USD"=>"463.39"}
        expect(WalletCentral.output_client("jon")).to eq expected_response
      end
    end

    context "with an non existing client" do
      it "return Not found message" do
        expect(WalletCentral.output_client("jose")).to eq "Not found"
      end
    end

  end



end