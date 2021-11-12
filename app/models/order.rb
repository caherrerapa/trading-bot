class Order < ApplicationRecord
  self.inheritance_column = :_type_disabled
  
  # Associations
  belongs_to :bot

  # Delegations
  delegate :pair_symbol, to: :bot
end
