import Config

if System.get_env("LOGFLARE_PUBLIC_API_KEY") do
  config :loadfest,
    api_key: System.get_env("LOGFLARE_PUBLIC_API_KEY")
end

if System.get_env("LOADFEST_ENDPOINT") do
  config :loadfest,
    endpoint: System.get_env("LOADFEST_ENDPOINT")
end
