defmodule Loadfest.Client do
  use Tesla

  def send(source_name, payload) do
    endpoint = Application.get_env(:loadfest, :endpoint)
    api_key = Application.get_env(:loadfest, :api_key)

    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, endpoint},
        {
          Tesla.Middleware.Headers,
          [
            {"Content-Type", "application/json"},
            {"x-api-key", api_key},
            {"User-Agent", "Loadfest"}
          ]
        }
      ],
      {Tesla.Adapter.Finch, name: Loadfest.Finch}
    )
    |> post!("/api/logs", Jason.encode!(payload), query: [source_name: source_name])
  end
end
