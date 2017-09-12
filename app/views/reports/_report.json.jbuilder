json.extract! report, :id, :name, :short_name, :description, :attribution, :created_at, :updated_at
json.url report_url(report, format: :json)
