defmodule LoadFest do
  @moduledoc """
  Load tester for Logflare.
  """

  @doc """
  Posts a lot to a Logflare source.

  ## Examples

  """
  def post() do
    api_key = Application.get_env(:loadfest, :logflare_api_key)
    source = Application.get_env(:loadfest, :logflare_source)
    url = "https://logflare.app/api/logs"
    user_agent = "Loadfest"
    line = "Derp"

    headers = [
      {"Content-type", "application/json"},
      {"X-API-KEY", api_key},
      {"User-Agent", user_agent}
    ]

    for line <- 1..100 do
      body = Jason.encode!(%{
        log_entry: line,
        source: source,
        })

      line = HTTPoison.post!(url, body, headers)
      IO.puts(line.status_code)
    end
  end

end
