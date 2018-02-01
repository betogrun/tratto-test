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

  describe "when a transfer is performed" do
    context "when there is no need for conversion" do

      it "updates the records" do
        jon_previous_amount = WalletCentral.find_client("jon")["USD"].to_f
        aray_previous_amount = WalletCentral.find_client("aray")["USD"].to_f

        WalletCentral.transfer('jon', 'aray', "USD", "200")

        jon_new_amount = WalletCentral.find_client("jon")["USD"].to_f
        aray_new_amount = WalletCentral.find_client("aray")["USD"].to_f

        expect(jon_new_amount).to eq(jon_previous_amount - 200.00)
        expect(aray_new_amount).to eq(aray_previous_amount + 200.00)
      end
    end

    context "when it is necessary to convert from EUR to BRL" do
      it "converts the value and update the records" do

        jon_previous_amount = WalletCentral.find_client("jon")["EUR"].to_f
        littlefinger_previous_amount = WalletCentral.find_client("littlefinger")["BRL"].to_f

        WalletCentral.transfer('jon', 'littlefinger', "EUR", "100.00")
        jon_new_amount = WalletCentral.find_client("jon")["EUR"].to_f
        littlefinger_new_amount = WalletCentral.find_client("littlefinger")["BRL"].to_f

        expect(jon_new_amount).to eq(jon_previous_amount - 100.00)
        expect(littlefinger_new_amount).to eq(littlefinger_previous_amount + 396.00)
        
      end
    end
  end



end