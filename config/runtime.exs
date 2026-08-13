import Config

if System.get_env("LOGFLARE_PUBLIC_API_KEY") do
  config :loadfest,
    api_key: System.get_env("LOGFLARE_PUBLIC_API_KEY")
end

case System.get_env("LOADFEST_SOURCE_NAMES", "") |> String.split(",", trim: true) do
  [] -> :ok
  source_names -> config :loadfest, source_names: source_names
end
