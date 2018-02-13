class CreateChunks < ActiveRecord::Migration[5.2]
  def change
    create_table :chunks do |t|
      t.text :code
      t.text :code_base64
      t.integer :size
      t.references :notebook, foreign_key: true

      t.timestamps
    end
    add_index :chunks, :code_base64
  end
end
