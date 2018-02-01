require 'json'
class WalletCentral

  def self.output 
    puts JSON.pretty_generate(wallets)
  end

  def self.output_client(client)
    client = wallets[client]
    return "Not found" if client.nil?
    client
  end

  def self.wallets
    wallets ||= File.readlines("lib/resources/wallets.csv")[1..-1]
      .map(&:strip)
      .map {|line| line.split(',')}
      .group_by(&:first)
      .transform_values do |value| 
        value.map{|v| v[1..-1] }.to_h 
      end
    wallets 
  end

  def self.tranfer(from, to, currency, amount)
    raise "Not enough funds" unless from.can_tranfer?

  end

 

  
end

