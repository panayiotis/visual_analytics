json.extract! report, :id, :name, :short_name, :created_at, :updated_at
json.url report_url(report, format: :json)
