class CreateSheets < ActiveRecord::Migration[5.1]
  def change
    create_table :sheets do |t|
      t.float :height
      t.float :width

      t.timestamps
    end
  end
end
