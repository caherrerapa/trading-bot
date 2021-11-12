class CreateBalances < ActiveRecord::Migration[6.1]
  def change
    create_table :balances do |t|
      t.string :asset
      t.decimal :free
      t.decimal :locked

      t.timestamps
    end
    add_index :balances, :asset, unique: true
  end
end
