json.extract! chunk, :key, :byte_size, :notebook_id,
              :created_at, :updated_at
json.url chunk_url(chunk, format: :json)
