
defmodule Loadfest.Client do
  use Tesla

  adapter Tesla.Adapter.Finch, name: Loadfest.Finch
  @api_key Application.get_env(:loadfest, :api_key)
  @endpoint Application.get_env(:loadfest, :endpoint)

  plug Tesla.Middleware.BaseUrl, @endpoint
  plug Tesla.Middleware.Headers, [
    {"Content-Type", "application/json"},
    {"x-api-key", @api_key}
  ]
  # plug Tesla.Middleware.JSON
  # plug Tesla.Middleware.Compression, format: "gzip"

  def send(source_name, payload) do
    post!("/api/logs", Jason.encode!(payload), query: [source_name: source_name])
  end
end
