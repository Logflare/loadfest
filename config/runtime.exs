import Config

if System.get_env("LOGFLARE_PUBLIC_API_KEY") do
  config :loadfest,
    api_key: System.get_env("LOGFLARE_PUBLIC_API_KEY")
end
