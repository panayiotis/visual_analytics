json.extract! dataset, :id, :name, :description,:schema, :uri, :created_at, :updated_at
json.url dataset_url(dataset, format: :json)
json.extract! dataset, :rows,:total_rows,:sql,:query, :levels
