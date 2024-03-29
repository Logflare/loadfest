import Config

config :loadfest, env: :prod
config :logger, level: :info

config :loadfest,
  source_names: [
    "loadfest.test.0",
    "loadfest.test.1",
    "loadfest.test.2",
    "loadfest.test.3",
    "loadfest.test.4",
    "loadfest.test.5",
    "loadfest.test.6",
    "loadfest.test.7",
    "loadfest.test.8",
    "loadfest.test.9",
    "loadfest.test.10"
  ]

# max_rps: 40
