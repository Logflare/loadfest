import Config

if System.get_env("LOGFLARE_PUBLIC_API_KEY") do
  config :loadfest,
    api_key: System.get_env("LOGFLARE_PUBLIC_API_KEY")
end

case System.get_env("LOADFEST_ENDPOINT") do
  endpoint when endpoint not in [nil, ""] ->
    config :loadfest, endpoint: endpoint

  _ ->
    :ok
end
