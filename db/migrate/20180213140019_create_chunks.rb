class CreateChunks < ActiveRecord::Migration[5.2]
  def change
    create_table :chunks do |t|
      t.text       :code,       null: false
      t.text       :key,        null: false
      t.bigint     :byte_size,  null: false
      t.references :notebook,   foreign_key: true

      t.timestamps
    end
    add_index :chunks, :key, unique: true
  end
end
