use Mix.Config

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"

config :loadfest,
  logflare_source_prod: "90819c3d-005e-47e7-91ed-d367192590bd",
  logflare_source_dev: "064a8344-7c8e-4494-be8d-557c95e95b01",
  # logflare_endpoint_prod: "https://logflare.app/api/logs",
  logflare_endpoint_prod: "https://logflarelogs.com/api/logs",
  logflare_endpoint_dev: "http://localhost:4000/api/logs"

import_config "secrets.exs"
