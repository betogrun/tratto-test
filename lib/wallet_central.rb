require 'json'
require 'wallet'
require 'client'

class WalletCentral

  def self.output 
    puts JSON.pretty_generate(Client.find_all)
  end

  def self.find_client(client)
    Client.find_by_name(client)
  end

  def self.transfer(from, to, currency, amount)
    client_from = Client.find_by_name(from)
    client_to = Client.find_by_name(to)
    unless client_from.transfer_to(client_to, currency, amount)
      client_from.error_messages
    end
  end

end

