defmodule LoadFest do
  @moduledoc """
  Load tester for Logflare.
  """

  @doc """
  Posts a lot to a Logflare source.

  ## Examples

  """
  def post(count) do
    api_key = Application.get_env(:loadfest, :logflare_api_key)
    source = Application.get_env(:loadfest, :logflare_source)
    url = "https://logflare.app/api/logs"
    user_agent = "Loadfest"

    headers = [
      {"Content-type", "application/json"},
      {"X-API-KEY", api_key},
      {"User-Agent", user_agent}
    ]

    for line <- 1..count do
      Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
        body = Jason.encode!(%{
          log_entry: line,
          source: source,
          })
        ### Should pull metrics from HTTPoison to do this correctly.
        prev = System.monotonic_time()
        request = HTTPoison.post!(url, body, headers, hackney: [pool: :loadfest_pool])
        next = System.monotonic_time()
        diff = next - prev
        IO.puts("#{request.status_code} | #{diff/1000000}ms")
      end)
    end
  end

  def post_dev(count) do
    api_key = "Z0mEDl_ZxB-5"
    source = "5f3c0076-b5c4-4c35-89d3-578282abf469"
    url = "http://localhost:4000/api/logs"
    user_agent = "Loadfest"

    headers = [
      {"Content-type", "application/json"},
      {"X-API-KEY", api_key},
      {"User-Agent", user_agent}
    ]

    for line <- 1..count do
      body = Jason.encode!(%{
        log_entry: line,
        source: source,
        })

      request = HTTPoison.post!(url, body, headers)
      IO.puts(request.status_code)
    end
  end

end
