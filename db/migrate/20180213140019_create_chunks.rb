class CreateChunks < ActiveRecord::Migration[5.2]
  def change
    create_table :chunks do |t|
      t.text       :key,        null: false
      t.text       :code,       null: false
      t.bigint     :byte_size
      t.bigint     :computation_time
      t.references :notebook,   foreign_key: true

      t.timestamps
    end
  end
end
