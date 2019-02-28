use Mix.Config

config :logger, :console, format: "$time $metadata[$level] $levelpad$message\n"

config :loadfest,
  logflare_source_prod: "186caa34-4390-4bbb-9594-687a007a77fe",
  logflare_source_dev: "dbe22007-eb52-43d9-9759-8c151bc5e4ff",
  logflare_endpoint_prod: "https://logflare.app/api/logs",
  logflare_endpoint_dev: "http://localhost:4000/api/logs"

import_config "secrets.exs"
