defmodule LoadFest do
  @moduledoc """
  Load tester for Logflare.
  """

  require Logger

  @doc """
  Posts async a lot to a Logflare source.

  ## Examples

  """
  def post_async(count, env) do
    for line <- 1..count do
      Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
        post("#{line}", env)
      end)
    end
  end

  def post_async(its, sleep, count, env) do
    for _a <- 1..its do
      Process.sleep(sleep)

      for line <- 1..count do
        Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
          post("#{line}", env)
        end)
      end
    end
  end

  @doc """
  Posts synchronously to a Logflare source.

  ## Examples

  """

  def post_sync(count, env) do
    for line <- 1..count do
      post("#{line}", env)
      Process.sleep(1000)
    end
  end

  defp post(line, env) do
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

    metadata = %{
      "response_code" => 200,
      "server" => "cloudflare",
      "cache_status" => "HIT",
      "user_agent" => "Google Chrome",
      "datacenter" => "aws",
      "real_ip" => "ip address"
    }

    body =
      Jason.encode!(%{
        log_entry: line,
        source: source,
        metadata: metadata
      })

    ### Should pull metrics from HTTPoison to do this correctly.

    prev = System.monotonic_time()
    request = HTTPoison.post!(url, body, headers, hackney: [pool: :loadfest_pool])
    next = System.monotonic_time()
    diff = next - prev
    response_headers = Enum.into(request.headers, %{})

    Logger.info(
      "#{request.status_code} | #{response_headers["x-rate-limit-source_remaining"]} | #{
        diff / 1_000_000
      }ms"
    )
  end

  defp json_file() do
    with {:ok, body} <- File.read("log_examples/papi_serp.json"),
         {:ok, json} <- Jason.decode(body),
         do: {:ok, json}
  end
end
