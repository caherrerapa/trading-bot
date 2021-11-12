class Bot < ApplicationRecord
    # Associations
    belongs_to :pair
    has_many   :orders, dependent: :destroy

    # Hooks
    after_commit   :create_orders, on: :create
    before_destroy :cancel_orders, prepend: true

    # Delegations
    delegate :symbol, :current_price, :base_asset, :quote_asset, :tick_size, :lot_size, :minimum_price, :maximum_price, to: :pair, prefix: true

    # Validations
    validates :buy_margin_percent, numericality: { greater_than_or_equal_to: 0.1 }
    validates :sell_margin_percent, numericality: { greater_than_or_equal_to: 0.1 }
    validate  :placed_orders_count_validation, on: :create

    private

    def create_orders
        #TODO: Background maybe?
        OrderCreationService.new(self).perform!
    end

    def cancel_orders
        OrderCancelationService.new(self).perform!
    end

    def placed_orders_count_validation
        # TODO: 
        true
    end
end
