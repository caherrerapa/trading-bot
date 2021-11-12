class PairSerializer < ActiveModel::Serializer
  attributes :id, :symbol, :current_price, :updated_at
end
