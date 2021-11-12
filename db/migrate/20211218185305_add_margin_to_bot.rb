class AddMarginToBot < ActiveRecord::Migration[6.1]
  def change
    add_column :bots, :buy_margin_percent, :decimal, default: 1.0
    add_column :bots, :sell_margin_percent, :decimal, default: 1.0
  end
end
