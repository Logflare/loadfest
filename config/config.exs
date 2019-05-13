use Mix.Config

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"

config :loadfest,
  logflare_source_prod: "9add149f-1ec4-4514-871e-ecd1b7358c79",
  logflare_source_dev: "bdc9a9b0-9c55-4938-aa92-64155261403a",
  # logflare_endpoint_prod: "https://logflare.app/api/logs",
  logflare_endpoint_prod: "https://logflarelogs.com/api/logs",
  logflare_endpoint_dev: "http://localhost:4000/api/logs"

import_config "secrets.exs"
