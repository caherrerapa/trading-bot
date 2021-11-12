class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :bot, null: false, foreign_key: true
      t.string :exchange_order_id
      t.string :client_order_id
      t.decimal :price
      t.decimal :original_quantity
      t.decimal :executed_quantity
      t.decimal :cumulative_quote_quantity
      t.string :status
      t.string :type
      t.string :side
      t.string :fills

      t.timestamps
    end
  end
end
