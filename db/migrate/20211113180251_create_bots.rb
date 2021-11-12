class CreateBots < ActiveRecord::Migration[6.1]
  def change
    create_table :bots do |t|
      t.decimal :minimum_price
      t.decimal :maximum_price
      t.integer :placed_orders_count
      t.decimal :total_investment
      t.decimal :entry_price
      t.decimal :take_profit_price
      t.boolean :use_base_asset, default: true # We still don't sell existing
      t.references :pair
      t.timestamps
    end
  end
end
