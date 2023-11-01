import Config

config :loadfest,
  source_names: ["loadfest.test.0", "loadfest.test.1"]

import_config("#{Mix.env()}.secret.exs")
