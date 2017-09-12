class CreateDatasets < ActiveRecord::Migration[5.1]
  def change
    create_table :datasets do |t|
      t.string :type
      t.string :name
      t.string :description
      t.string :schema_json
      t.string :attribution
      t.string :uri

      t.timestamps
    end
  end
end
