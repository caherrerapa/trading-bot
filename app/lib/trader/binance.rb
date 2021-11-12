module Trader
  class Binance
    attr_accessor :maker_commission, :taker_commission, :client

    def initialize
      @client = Client.new
    end

    # Operations
    def load_pairs!
      puts 'Loading Pairs'

      data = client.exchange_info.deep_symbolize_keys!

      pairs = data[:symbols].map do |pair|
        {
          symbol:           pair[:symbol],
          base_asset:       pair[:baseAsset],
          quote_asset:      pair[:quoteAsset],
          tick_size:        pair[:filters].find { |filter| filter[:filterType] == 'PRICE_FILTER'}[:tickSize],
          minimum_price:    pair[:filters].find { |filter| filter[:filterType] == 'PRICE_FILTER'}[:minPrice],
          maximum_price:    pair[:filters].find { |filter| filter[:filterType] == 'PRICE_FILTER'}[:maxPrice],
          minimum_size:     pair[:filters].find { |filter| filter[:filterType] == 'LOT_SIZE'}[:minQty],
          maximum_size:     pair[:filters].find { |filter| filter[:filterType] == 'LOT_SIZE'}[:maxQty],
          lot_size:         pair[:filters].find { |filter| filter[:filterType] == 'LOT_SIZE'}[:stepSize],
          minimum_notional: pair[:filters].find { |filter| filter[:filterType] == 'MIN_NOTIONAL'}[:minNotional],
          created_at:       Time.current,
          updated_at:       Time.current
        }
      end
      Pair.upsert_all(pairs, unique_by: :symbol)
    end

    def load_balances!
      puts 'Querying Balances'

      data = client.account_info.deep_symbolize_keys!
      balances = data[:balances].map do |b|
        {
          asset:      b[:asset],
          free:       b[:free].to_f,
          locked:     b[:locked].to_f,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      @maker_commission = data[:makerCommission]
      @taker_commission = data[:takerCommission]

      Balance.upsert_all(balances, unique_by: :asset)
    end

    def create_order!(symbol:, side:, quantity:, price:, bot:)
      return if quantity <= 0.0

      payload = client.create_order!(symbol:        symbol,
                                     side:          side,
                                     type:          'LIMIT',
                                     time_in_force: 'GTC',
                                     quantity:      quantity,
                                     price:         price)

      raise payload['msg'] if payload.has_key?('msg') && payload.has_key?('code')

      attributes = process_order(payload).merge(bot: bot)

      Order.create!(attributes)
    rescue StandardError => e
      puts "#{e.message}"
    end

    def cancel_orders!(bot:)
      order_ids = bot.orders.where.not(status: ['CANCELLED']).pluck(:exchange_order_id)
      order_ids.each do |exchange_order_id|
        payload = client.cancel_order!(symbol: bot.pair_symbol, order_id: exchange_order_id)
      end
    end

    def restart_bots!
      load_balances!
      load_pairs!
      puts 'Updating Bot Orders'
      Bot.all.each do |bot|
        next unless bot.is_active?
        # Update all orders that haven't been filled
        unfilled_bot_orders = bot.orders.where.not(status: 'FILLED')

        unfilled_bot_orders.each do |order|
          payload    = client.query_order(symbol: order.pair_symbol, order_id: order.exchange_order_id)
          attributes = process_order(payload)
          order.update!(attributes)
        end

        # How many orders we need to create
        bot_current_order_count = bot.orders.where(status: 'NEW').count
        new_order_count = bot.placed_orders_count - bot_current_order_count

        # Get the latest n orders filled
        filled_orders = bot.orders.where(status: 'FILLED').order('updated_at DESC').limit(new_order_count)

        filled_orders.each do |filled_order|
          new_side  = calculate_new_side(filled_order.side)
          new_price = calculate_new_price(bot, bot.pair_symbol, filled_order.side, filled_order.price)

          puts "new price symbol: #{bot.pair_symbol}, side: #{new_side}, quantity: #{filled_order.original_quantity}, price: #{new_price}"
          trade(symbol: bot.pair_symbol, side: new_side, quantity: filled_order.original_quantity, price: new_price, bot: bot)
        end
      end
    end

    def listen!
      EM.run do
        open            = proc { puts "Connected #{Time.now}" }
        stream_message  = proc { |e| process_stream_event(e.data) }
        account_message = proc { |e| process_account_event(e.data) }
        error           = proc { |_e| raise 'Error: Generic error' }
        close           = proc { |_e| raise 'Error: Connection closed' }

        # Bundle our event handlers into Hash
        stream_methods  = { open: open, message: stream_message, error: error, close: close }
        account_methods = { open: open, message: account_message, error: error, close: close }

        # As well as partial_book_depth
        streams =  []
        streams << { type: 'arr', symbol: '!ticker' }

        client.multi(streams: streams, methods: stream_methods)

        # Get updates on balances
        client.user_data(listen_key: listen_key, methods: account_methods)

        # Keep Alive every 10 minutes, the stream will be closed every 60 minutes otherwise.
        EM.add_periodic_timer(300) do
          # This is only for the account
          puts "Maintaining connections: #{Time.current}"
          client.keep_alive_stream!
          client.ping!
        rescue StandardError => e
          puts e.stack_trace
        end

        EM.add_timer(15) do
          restart_bots!
        end
      rescue StandardError => e
        pp 'Standard error'
        pp e.message
        pp e.stack_trace
      end
    end

    def price(symbol:)
      payload = rest.price(symbol: symbol)

      raise payload['msg'] if payload.has_key?('msg') && payload.has_key?('code')

      payload['price']
    end

    def process_order(payload)
      mappings = { 'orderId' => :exchange_order_id, 'clientOrderId' => :client_order_id, 'price' => :price, 'origQty' => :original_quantity, 'executedQty' => :executed_quantity, 'cummulativeQuoteQty' => :cumulative_quote_quantity, 'status' => :status, 'type' => :type, 'side' => :side, 'fills' => :fills }
      payload.transform_keys(&mappings.method(:[])).delete_if { |k, v| k == nil || v == nil }
    end

    def process_stream_event(payload)
      parsed_event = parse_event(payload)

      stream_symbol, stream_type = parsed_event[:stream].split('@')

      case stream_type
      when 'arr'
        parsed_event[:data].map do |pair|
          $redis.set("ticker:#{pair[:s]}", pair[:c])
        end
      else
        $redis.set("#{stream_type}:#{stream_symbol}", parsed_event[:data])
      end
    end

    def process_account_event(payload)
      parsed_event = parse_event(payload)

      load_balances!
      if parsed_event[:e] == 'executionReport'
        # We need to create an order in the opposite direction
        return unless parsed_event[:x] == 'TRADE'

        # We need to create an order in the opposite direction
        client_order_id   = parsed_event[:c]
        executed_symbol   = parsed_event[:s]
        executed_side     = parsed_event[:S]
        executed_quantity = parsed_event[:q].to_f
        executed_price    = parsed_event[:L].to_f
        status            = parsed_event[:X]

        puts parsed_event

        order = Order.find_by(client_order_id: client_order_id)

        return unless order

        order.update(status: status, executed_quantity: executed_quantity)

        # We don't wanna create partial orders only when they are completely filled

        return unless parsed_event[:X] == 'FILLED'

        puts parsed_event[:X]

        bot = order.bot

        return unless bot.is_active?

        new_side  = calculate_new_side(executed_side)
        new_price = calculate_new_price(bot, executed_symbol, executed_side, executed_price)

        puts "new price symbol: #{executed_symbol}, side: #{new_side}, quantity: #{executed_quantity}, price: #{new_price}"
        trade(symbol: executed_symbol, side: new_side, quantity: executed_quantity, price: new_price, bot: order.bot)
      end
    end

    def trade(symbol:, side:, quantity: nil, price: nil, bot:)
      pair = Pair.find_by(symbol: symbol)

      if side == 'SELL'
        balance = Balance.find_by(asset: pair.quote_asset)

        return unless balance.free > 0.0

        sell_price    = price
        sell_quantity = quantity || pair.minimum_notional

        # Get order from the exchange and from there get the bot
        create_order!(symbol: symbol, side: side, quantity: sell_quantity, price: sell_price, bot: bot)
      end

      if side == 'BUY'
        balance = Balance.find_by(asset: pair.base_asset)

        return unless balance.free > 0.0

        buy_price    = price
        buy_quantity = quantity || pair.minimum_notional

        # Get order from the exchange and from there get the bot
        create_order!(symbol: symbol, side: side, quantity: buy_quantity, price: buy_price, bot: bot)
      end
    rescue StandardError => e
      puts e
    end

    def calculate_new_side(executed_side)
      executed_side == 'BUY' ? 'SELL' : 'BUY'
    end

    def calculate_new_price(bot, symbol, executed_side, executed_price)
      # TODO: Calculate automatically
      pair = bot.pair

      buy_spread  = bot.buy_margin_percent
      sell_spread = bot.sell_margin_percent

      current_price = BigDecimal(pair.current_price)

      case executed_side
      when 'BUY'
        new_price = executed_price * (1 + maker_commission / 1000.0 * sell_spread)
        new_price = new_price < current_price ? current_price : new_price
      when 'SELL'
        new_price = executed_price * (1 - maker_commission / 1000.0 * buy_spread)
        new_price = new_price > current_price ? current_price : new_price
      end

      new_price = BigDecimal('%.20f' % new_price) - (BigDecimal('%.20f' % new_price) % BigDecimal('%.20f' % pair.tick_size))
      puts "Symbol #{symbol}, Executed Price #{executed_price}, New price #{new_price} Executed side #{executed_side} Executed Price #{executed_price}"
      new_price
    end

    def listen_key
      @_listen_key ||= client.listen_key['listenKey']
    end

    def parse_event(payload)
      JSON.parse(payload, symbolize_names: true)
    end

    class Client
      delegate :exchange_info, :account_info, :query_order, :create_order!, :cancel_order!, :create_test_order, :listen_key, :keep_alive_stream!,to: :rest
      delegate :partial_book_depth, :user_data, :all_market_ticker, :all_market_mini_ticker, :multi, :ping!, to: :ws

      def rest
        @_rest ||= ::Binance::Client::REST.new api_key: Rails.configuration.binance_api_key, secret_key: Rails.configuration.binance_secret_key
      end

      def ws
        @_ws ||= ::Binance::Client::WebSocket.new
      end
    end
  end
end