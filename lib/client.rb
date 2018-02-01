require 'wallet'
require 'pry'

class Client
  attr_accessor :name, :wallets, :error_messages

  def initialize(name, wallets)
    @name = name
    @wallets = wallets 
    @error_messages = []
  end

  def as_json(options={})
  {
	  name: @name,
	  wallets: @wallets.map {|w| [w.currency, w.amount] }.to_h
  }
 end
  
  def to_json(*options)
   as_json(*options).to_json(*options)
  end

  def save
    self.wallets.each do |wallet|
      $records[self.name][wallet.currency] = wallet.amount
    end
  end

  def self.find_by_name(name)
    return "Client #{name} not found" if records[name].nil?
    self.build(name)
  end

  def self.find_all
    records.map {|k,v| build(k)}
  end

  def wallet(currency)
    self.wallets.find {|w| w.currency == currency }
  end


  def transfer_to(other_client, currency, amount)
    
    validate_transfer(currency, amount)
    return false unless self.error_messages.empty?
    
    from_wallet = wallet(currency)
    
    to_wallet = other_client.wallet(currency) || other_client.wallets.first
    
    if from_wallet.currency == to_wallet.currency
      to_wallet.amount = (to_wallet.amount.to_f + amount.to_f).to_s
    else
      converted_amount = convert(from_wallet.currency, to_wallet.currency, amount)
      to_wallet.amount = (to_wallet.amount.to_f + converted_amount).to_s
    end
    from_wallet.amount = (from_wallet.amount.to_f - amount.to_f).to_s

    self.save
    other_client.save
  end

  private

  def validate_transfer(currency, amount)
    wallet = wallet(currency)
    if wallet.nil?
      self.error_messages << "Client #{self.name} does not have a #{currency} wallet."  
    elsif wallet.amount.to_f < amount.to_f
      self.error_messages << "Client #{self.name} does not have enough funds." 
    end
  end

  def self.build(client_name)
    wallets = records[client_name].map {|k,v| Wallet.new(k,v)}
    self.new(client_name, wallets)
  end

  def self.records
    $records ||= File.readlines("lib/resources/wallets.csv")[1..-1]
      .map(&:strip)
      .map {|line| line.split(',')}
      .group_by(&:first)
      .transform_values do |value| 
        value.map{|v| v[1..-1] }.to_h 
      end
    $records 
  end

  def currency_factor
    {
      ["USD", "BRL"] => 3.16,
      ["USD", "EUR"] => 0.8,
      ["EUR", "USD"] => 1.24,
      ["EUR", "BRL"] => 3.96,
      ["BRL", "USD"] => 0.31,
      ["BRL", "EUR"] => 0.25
    }
  end

  def convert(from, to, amount)
    currency_factor[[from, to]] * amount.to_f
  end
  
end