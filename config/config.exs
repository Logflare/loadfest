import Config

config :logger, level: :debug
config :logger, :console, format: "$time $metadata[$level] $message\n"

config :loadfest,
  logflare_source_prod: "bb11fa84-a547-4bd5-8645-f60a5a2c5b38",
  logflare_source_dev: "7d6dfdf9-c717-436d-a542-6e960a5f510a",
  logflare_source_stag: "e1474a2f-bdc1-46a8-a5b4-4816f59dcac3",
  # logflare_endpoint_prod: "https://logflare.app/api/logs",
  logflare_endpoint_prod: "https://api.logflare.app/logs",
  logflare_endpoint_dev: "http://localhost:4000/logs",
  logflare_endpoint_stag: "https://api.logflarestaging.com/logs",
  endpoint: "https://test.logflarestaging.com"

import_config("#{Mix.env()}.exs")
