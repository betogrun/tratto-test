require_relative '../lib/wallet_central'
require 'pry'
RSpec.describe "WalletCentral" do
 

  describe "when find_client message is sent" do

    context "with an existing client" do
    
      it "shows only client's wallets" do
        expected_response = "{\"name\":\"jon\",\"wallets\":{\"EUR\":\"868.65\",\"USD\":\"463.39\"}}"
        response = WalletCentral.find_client("jon").to_json
        expect(response).to eq(expected_response)
      end
    end

    context "with an non existing client" do
      it "return Not found message" do
        errors = WalletCentral.find_client("jose")
        expect(errors).to include("Client jose not found")
      end
    end

  end

  describe "when a transfer is performed" do
    context "when there is no need for conversion" do

      it "updates the records" do
        jon_previous_amount = WalletCentral.find_client("jon").wallet("USD").amount.to_f
        aray_previous_amount = WalletCentral.find_client("aray").wallet("USD").amount.to_f

        WalletCentral.transfer('jon', 'aray', "USD", "200")

        jon_new_amount = WalletCentral.find_client("jon").wallet("USD").amount.to_f
        aray_new_amount = WalletCentral.find_client("aray").wallet("USD").amount.to_f

        expect(jon_new_amount).to eq(jon_previous_amount - 200.00)
        expect(aray_new_amount).to eq(aray_previous_amount + 200.00)
      end
    end

    context "when it is necessary to convert from EUR to BRL" do
      it "converts the value and update the records" do

        jon_previous_amount = WalletCentral.find_client("jon").wallet("EUR").amount.to_f
        littlefinger_previous_amount = WalletCentral.find_client("littlefinger").wallet("BRL").amount.to_f

        WalletCentral.transfer('jon', 'littlefinger', "EUR", "100.00")
        jon_new_amount = WalletCentral.find_client("jon").wallet("EUR").amount.to_f
        littlefinger_new_amount = WalletCentral.find_client("littlefinger").wallet("BRL").amount.to_f

        expect(jon_new_amount).to eq(jon_previous_amount - 100.00)
        expect(littlefinger_new_amount).to eq(littlefinger_previous_amount + 396.00)
        
      end
    end

    context "when client does not have enough money" do
      it "returns a 'Not enough funds' error message" do
        errors = WalletCentral.transfer('jon', 'aray', "USD", "2000")

        expect(errors).to include("Client jon does not have enough funds.")
      end
    end

    context "when client does not have a wallet with a required currency" do
      it "returns a 'Not required currency wallet' message" do
        errors = WalletCentral.transfer('jon', 'aray', "BRL", "20")

        expect(errors).to include("Client jon does not have a BRL wallet.")
      end
    end
    
  end



end