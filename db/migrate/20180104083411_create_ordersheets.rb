class CreateOrdersheets < ActiveRecord::Migration[5.1]
  def change
    create_table :ordersheets do |t|
      t.integer :amount
      t.float :height
      t.float :width

      t.timestamps
    end
  end
end
