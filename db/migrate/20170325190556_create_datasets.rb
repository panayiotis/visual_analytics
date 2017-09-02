class CreateDatasets < ActiveRecord::Migration[5.0]
  def change
    create_table :datasets do |t|
      t.string :type
      t.string :name
      t.string :description
      t.string :schema_json
      t.string :uri

      t.timestamps
    end
  end
end
