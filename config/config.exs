use Mix.Config

config :loadfest,
  logflare_source_prod: "186caa34-4390-4bbb-9594-687a007a77fe",
  logflare_source_dev: "588a18a2-71b0-4150-a7af-da11dd2f17c6",
  logflare_endpoint_prod: "https://logflare.app/api/logs",
  logflare_endpoint_dev: "http://localhost:4000/api/logs"

import_config "secrets.exs"
