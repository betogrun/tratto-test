class Wallet
  attr_accessor :currency, :amount

  def initialize(currency, amount)
    @currency = currency
    @amount = amount
  end
  
end
