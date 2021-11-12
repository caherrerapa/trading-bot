class AddIsActiveToBot < ActiveRecord::Migration[6.1]
  def change
    add_column :bots, :is_active, :boolean, default: true
  end
end
