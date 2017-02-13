config = { url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } }
$redis = Redis.new(config)
