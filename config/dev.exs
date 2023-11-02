import Config

config :loadfest,
  source_names: ["loadfest.test.0", "loadfest.test.1"]

import_config "dev.secret.exs"
