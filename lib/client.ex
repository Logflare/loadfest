defmodule Loadfest.Client do
  use Tesla

  def send(source_name, payload) do
    endpoint = Application.get_env(:loadfest, :endpoint)
    api_key = Application.get_env(:loadfest, :api_key)

    {payload, headers} = if(length(payload.batch) > 99, do: "gzip", else: Enum.random(["gzip", nil]))
    |> case do
      nil -> {Jason.encode!(payload), []}
      "gzip" -> {:zlib.gzip(Jason.encode!(payload)), [{"Content-Encoding", "gzip"}]}

    end
    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, endpoint},
        {
          Tesla.Middleware.Headers,
          [
            {"Content-Type", "application/json"},
            {"x-api-key", api_key},
            {"User-Agent", "Loadfest"}
          ] ++ headers
        }
      ],
      {Tesla.Adapter.Finch, name: Loadfest.Finch}
    )
    |> post!("/logs", payload, query: [source_name: source_name])
  end
end
