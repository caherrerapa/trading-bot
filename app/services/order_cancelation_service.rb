require 'bigdecimal'
class OrderCancelationService
    def initialize(bot)
        @bot = bot
    end

	def trader
		@_trader ||= Trader::Binance.new
	end

	def perform!
		trader.cancel_orders!(bot: bot)
    end

    private 

    attr_reader :bot
end