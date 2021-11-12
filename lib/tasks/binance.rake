namespace :binance do
  desc "Store the symbols"
  task load_pairs: :environment do
    trader = Trader::Binance.new
    trader.load_pairs!
  end

  task load_balances: :environment do
    trader = Trader::Binance.new
    trader.load_balances!
  end
end
