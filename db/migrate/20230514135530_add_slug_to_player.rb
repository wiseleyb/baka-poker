class AddSlugToPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :slug, :string, null: false, index: true
  end
end
