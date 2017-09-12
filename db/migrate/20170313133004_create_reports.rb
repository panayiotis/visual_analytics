class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.string :name
      t.string :short_name
      t.string :description
      t.string :attribution

      t.timestamps
    end
  end
end
