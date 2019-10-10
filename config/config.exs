use Mix.Config

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"

config :loadfest,
  logflare_source_prod: "6070d25d-93e4-44e2-99a7-b9e792cbe9bb",
  logflare_source_dev: "743a50f8-8b59-46a3-bd53-3ba104432857",
  logflare_source_stag: "e1474a2f-bdc1-46a8-a5b4-4816f59dcac3",
  # logflare_endpoint_prod: "https://logflare.app/api/logs",
  logflare_endpoint_prod: "https://logflarelogs.com/api/logs",
  logflare_endpoint_dev: "http://localhost:4000/api/logs",
  logflare_endpoint_stag: "https://api.logflarestaging.com/logs"

import_config "secrets.exs"
