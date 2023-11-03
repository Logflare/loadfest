import Config

config :loadfest, env: :prod
config :logger, level: :info

config :loadfest,
  source_names: ["loadfest.test.0", "loadfest.test.1"]
