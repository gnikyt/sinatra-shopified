class CreateShop < ActiveRecord::Migration[4.2]
  def up
    create_table :shops do |t|
      t.string :shop
      t.string :token, null: true
    end
  end

  def down
    drop_table :shops
  end
end
