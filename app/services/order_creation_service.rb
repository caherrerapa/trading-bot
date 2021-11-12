require 'bigdecimal'
class OrderCreationService
	delegate :minimum_price, 
			 :maximum_price, 
			 :placed_orders_count, 
			 :pair_symbol, 
			 :pair_tick_size, 
			 :pair_base_asset, 
			 :pair_quote_asset, 
			 :use_base_asset?,
			 :pair_lot_size,
			 :pair_tick_size,
	         to: :bot

    def initialize(bot)
        @bot = bot
    end

	def trader
		@_trader ||= Trader::Binance.new
	end

	def pair
		@_pair ||= Pair.find_by(symbol: pair_symbol)
	end

	def balance
		@_balance ||= Balance.find_by(asset: asset)
	end

	def asset
		@_asset ||= use_base_asset? ? pair_base_asset : pair_quote_asset
	end

	def side
		@_side ||= use_base_asset? ? 'SELL' : 'BUY'
	end

	def current_price
		trader.price(symbol)
	end

	def load_balances!
		trader.load_balances!
	end

	def free_balance
		balance.free
	end

	def step
		step = (maximum_price - minimum_price) / (placed_orders_count - 1)
		step = step > pair_tick_size ? step : pair_tick_size
		BigDecimal('%f' % step) - (BigDecimal('%f' % step) % BigDecimal('%.20f' % pair_tick_size))
	end

	def quantity
		puts "Quantity. Free balance: #{free_balance}, Asset: #{asset}, Use base asset: #{use_base_asset?}"

		quantity = BigDecimal(free_balance / placed_orders_count)
		BigDecimal('%f' % quantity) - (BigDecimal('%f' % quantity) % BigDecimal('%f' % pair_lot_size))
	end

	def perform!
		load_balances!

		puts "min:  #{"%f" % minimum_price} max: #{"%f" % maximum_price} step: #{"%f" % step}"

		range = minimum_price..maximum_price

		# raise "Error: Quantity (#{quantity}) smaller than allowed lot size (#{pair_lot_size})" if quantity < pair_lot_size

		if free_balance > 0.0 && quantity > 0.0
			range.step(step) do |price|
				puts "value #{price}, quantity #{quantity}, side #{side}"
				trader.create_order!(symbol: pair_symbol, side: side, quantity: quantity, price: price, bot: bot)
			end
		else
			puts 'No balance available. Try selling mode'
		end
	end

	private

	attr_reader :bot
end