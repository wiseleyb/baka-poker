class Setup < ActiveRecord::Migration[7.0]
  def up
    create_table :players do |t|
      t.string :name
      t.string :image_name
      t.timestamps
    end

    Player.reset_column_information
    Player.reset!

    create_table :games do |t|
      t.json :data
      t.timestamps
    end
  end

  def down
    drop_table :players
    drop_table :games
  end
end
