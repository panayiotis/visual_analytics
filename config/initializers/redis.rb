config = { url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/1' } }
Redis.current = Redis.new(config)
