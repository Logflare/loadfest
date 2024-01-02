defmodule Loadfest.Client do
  use Tesla

  def send(source_name, payload) do
    endpoint = Application.get_env(:loadfest, :endpoint)
    api_key = Application.get_env(:loadfest, :api_key)

    middlewares = case Enum.random(["gzip", nil]) do
      nil ->
        []
      "gzip" ->
          [
            {Tesla.Middleware.Compression, format: "gzip"},
          ]
    end

    Tesla.client(
      [
        {Tesla.Middleware.Timeout, timeout: 15_000},
        {Tesla.Middleware.Retry, delay: 500, max_retries: 10, max_delay: 5_000},
        {Tesla.Middleware.BaseUrl, endpoint},
        {
          Tesla.Middleware.Headers,
          [
            {"Content-Type", "application/json"},
            {"x-api-key", api_key},
            {"User-Agent", "Loadfest"}
          ]
        }
      ] ++ middlewares,
      {Tesla.Adapter.Finch, name: Loadfest.Finch}
    )

    |> post!("/logs", Jason.encode!(payload), query: [source_name: source_name])
  end
end
