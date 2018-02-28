class CreateNotebooks < ActiveRecord::Migration[5.2]
  def change
    create_table :notebooks do |t|
      t.string :name
      t.boolean :public
      t.string :adapter
      t.string :pack
      t.text :state_json
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
