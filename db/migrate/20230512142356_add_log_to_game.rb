class AddLogToGame < ActiveRecord::Migration[7.0]
  def change
    create_table :game_hands do |t|
      t.integer :game_id, null: false, index: true
      t.text :log
      t.timestamps
    end
  end
end
