class CreatePairs < ActiveRecord::Migration[6.1]
  def change
    create_table :pairs do |t|
      t.string :symbol
      t.string :quote_asset
      t.string :base_asset
      t.decimal :tick_size
      t.decimal :minimum_price
      t.decimal :maximum_price
      t.decimal :lot_size
      t.decimal :minimum_size
      t.decimal :maximum_size
      t.decimal :minimum_notional

      t.timestamps
    end
    add_index :pairs, :symbol, unique: true
  end
end
