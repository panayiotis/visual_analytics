json.extract! notebook, :id, :name, :public, :adapter, :pack, :state,
              :user_id, :created_at, :updated_at
json.url notebook_url(notebook, format: :json)
