defmodule LoadFest do
  @moduledoc """
  Load tester for Logflare.
  """

  @doc """
  Posts a lot to a Logflare source.

  ## Examples

  """
  def post_async(count, env) do
    key = String.to_atom("logflare_api_key" <> "_" <> env)
    source_key = String.to_atom("logflare_source" <> "_" <> env)
    endpoint = String.to_atom("logflare_endpoint" <> "_" <> env)

    api_key = Application.get_env(:loadfest, key)
    source = Application.get_env(:loadfest, source_key)
    url = Application.get_env(:loadfest, endpoint)
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

  def post_sync(count, env) do
    key = String.to_atom("logflare_api_key" <> "_" <> env)
    source_key = String.to_atom("logflare_source" <> "_" <> env)
    endpoint = String.to_atom("logflare_endpoint" <> "_" <> env)

    api_key = Application.get_env(:loadfest, key)
    source = Application.get_env(:loadfest, source_key)
    url = Application.get_env(:loadfest, endpoint)
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

      prev = System.monotonic_time()
      request = HTTPoison.post!(url, body, headers)
      next = System.monotonic_time()
      diff = next - prev
      IO.puts("#{request.status_code} | #{diff/1000000}ms")
      Process.sleep(1000)
    end
  end

end
