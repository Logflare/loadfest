import Config

config :loadfest, env: :dev

config :loadfest,
  source_names: ["loadfest.test.0", "loadfest.test.1"]

# Realistic payload sources — uncomment to use fixture-shaped payloads per source type.
# Override at runtime with: LOADFEST_SOURCE_NAMES=loadfest.edge_log,loadfest.postgres
# config :loadfest,
#   source_names: [
#     "loadfest.edge_log",
#     "loadfest.postgres",
#     "loadfest.auth_middleware",
#     "loadfest.realtime_log",
#     "loadfest.storage",
#     "loadfest.api_gateway_trace"
#   ]

import_config "dev.secret.exs"
