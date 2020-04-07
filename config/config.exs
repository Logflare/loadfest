use Mix.Config

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"

config :loadfest,
  logflare_source_prod: "b03decb3-2cf9-4835-a3df-3d8502eade75",
  logflare_source_dev: "d6b815d4-4596-4d88-be83-46f1a2e8d165",
  logflare_source_stag: "e1474a2f-bdc1-46a8-a5b4-4816f59dcac3",
  # logflare_endpoint_prod: "https://logflare.app/api/logs",
  logflare_endpoint_prod: "https://api.logflare.app/logs",
  logflare_endpoint_dev: "http://localhost:4000/api/logs",
  logflare_endpoint_stag: "https://api.logflarestaging.com/logs"

import_config "secrets.exs"
