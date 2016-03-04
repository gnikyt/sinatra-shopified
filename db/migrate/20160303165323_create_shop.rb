class CreateShop < ActiveRecord::Migration
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
