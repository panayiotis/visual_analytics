json.extract! chunk, :id, :code, :code_base64, :size, :report_id, :created_at, :updated_at
json.url chunk_url(chunk, format: :json)
