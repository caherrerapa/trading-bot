class Pair < ApplicationRecord
    # Associations
    has_many :bots
    
    # Validations
    validates :symbol, uniqueness: true

    def current_price
        $redis.get("ticker:#{symbol}")
    end
end
