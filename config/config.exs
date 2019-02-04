use Mix.Config

config :loadfest,
  logflare_source_prod: "186caa34-4390-4bbb-9594-687a007a77fe",
  logflare_source_dev: "ce4861fe-7be9-4f09-80f3-62a1239c511b",
  logflare_endpoint_prod: "https://logflare.app/api/logs",
  logflare_endpoint_dev: "http://localhost:4000/api/logs"

import_config "secrets.exs"
