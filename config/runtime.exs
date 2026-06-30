import Config

if System.get_env("LOGFLARE_PUBLIC_API_KEY") do
  config :loadfest,
    api_key: System.get_env("LOGFLARE_PUBLIC_API_KEY")
end

if System.get_env("LOADFEST_SOURCE_MODE") == "realistic" do
  default_sources =
    "edge_log,postgres,auth_middleware,realtime_log,storage,api_gateway_trace"

  prefixes =
    System.get_env("LOADFEST_REALISTIC_SOURCES", default_sources)
    |> String.split(",", trim: true)

  config :loadfest,
    source_mode: :realistic,
    source_names: Enum.map(prefixes, &"loadfest.#{&1}")
end
