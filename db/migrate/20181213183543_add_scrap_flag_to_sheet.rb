class AddScrapFlagToSheet < ActiveRecord::Migration[5.1]
  def change
    add_column :sheets, :isScrap, :boolean, default: false
  end
end
