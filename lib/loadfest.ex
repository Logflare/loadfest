defmodule LoadFest do
  @moduledoc """
  Load tester for Logflare.
  """

  require Logger

  @doc """
  POSTs async a lot to a Logflare source.

  ## Examples

  """
  def post_async(count, env) do
    for line <- 1..count do
      Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
        post("#{line}", env)
      end)
    end
  end

  def post_async_json(count, batch_size, env) do
    for line <- 1..count do
      Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
        post_json(batch_size, env)
      end)
    end
  end

  @doc """
  POSTs async to a logflare source with more options.

  ## Examples

  """
  def post_async(its, sleep, count, batch_size, env) do
    for _a <- 1..its do
      Process.sleep(sleep)

      for line <- 1..count do
        Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
          post_json(batch_size, env)
        end)
      end
    end
  end

  @doc """
  POSTs async to a logflare source in batches.

  ## Examples

  """
  def post_async_batch(its, sleep, count, env) do
    for _a <- 1..its do
      Process.sleep(sleep)

      for line <- 1..count do
        Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
          post_batch("#{line}", env)
        end)
      end
    end
  end

  def post_async_batch_json(its, sleep, count, batch_size, env) do
    for _a <- 1..its do
      Process.sleep(sleep)

      for line <- 1..count do
        Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
          post_json(batch_size, env)
        end)
      end
    end
  end

  @doc """
  GETs a url a lot.

  ## Examples

  """
  def get_async(its, sleep, count, url) do
    for _a <- 1..its do
      Process.sleep(sleep)

      for _line <- 1..count do
        Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
          get(url)
        end)
      end
    end
  end

  @doc """
  POSTs synchronously to a Logflare source.

  ## Examples

  """
  def post_sync(count, env) do
    for line <- 1..count do
      post("#{line}", env)
      Process.sleep(0)
    end
  end

  def post_sync_batch(count, env) do
    for line <- 1..count do
      post_batch("#{line}", env)
      Process.sleep(0)
    end
  end

  defp get(url) do
    prev = System.monotonic_time()
    request = HTTPoison.get!(url, [], hackney: [pool: :loadfest_pool])
    next = System.monotonic_time()
    diff = next - prev

    Logger.info("#{request.status_code} | #{diff / 1_000_000}ms")
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

  def post_json(batch_size, env) do
    key = String.to_atom("logflare_api_key" <> "_" <> env)
    source_key = String.to_atom("logflare_source" <> "_" <> env)
    endpoint = String.to_atom("logflare_endpoint" <> "_" <> env)
    api_key = Application.get_env(:loadfest, key)
    source = Application.get_env(:loadfest, source_key)
    url = Application.get_env(:loadfest, endpoint) <> "/json"
    user_agent = "Loadfest"
    batch_size = batch_size - 1

    headers = [
      {"Content-type", "application/json"}
    ]

    params = %{"source_id" => source, "api_key" => api_key}

    batch =
      0..batch_size
      |> Enum.map(fn _x -> LoadFest.Json.event() end)
      |> Jason.encode!()

    ### Should pull metrics from HTTPoison to do this correctly.

    prev = System.monotonic_time()

    request =
      HTTPoison.post!(url, batch, headers, params: params, hackney: [pool: :loadfest_pool])

    next = System.monotonic_time()
    diff = next - prev
    response_headers = Enum.into(request.headers, %{})

    Logger.info(
      "#{request.status_code} | #{response_headers["x-rate-limit-source_remaining"]} | #{
        diff / 1_000_000
      }ms"
    )
  end

  defp post_batch(line, env) do
    key = String.to_atom("logflare_api_key" <> "_" <> env)
    source_key = String.to_atom("logflare_source" <> "_" <> env)
    endpoint = String.to_atom("logflare_endpoint" <> "_" <> env)

    api_key = Application.get_env(:loadfest, key)
    source = Application.get_env(:loadfest, source_key)
    url = Application.get_env(:loadfest, endpoint) <> "/elixir/logger"
    user_agent = "Loadfest"

    headers = [
      {"Content-type", "application/json"},
      {"X-API-KEY", api_key},
      {"User-Agent", user_agent}
    ]

    metadata = %{
      custom_user_data: %{
        address: %{
          city: "New York",
          st: "NY",
          street: "123 W Main St",
          zip: "11111"
        },
        company: "Apple",
        id: 38,
        login_count: 154,
        vip: true
      },
      datacenter: "aws",
      ip_address: "100.100.100.100",
      request_headers: %{connection: "close", user_agent: "chrome"},
      request_method: "POST"
    }

    batch =
      0..100
      |> Enum.map(fn x ->
        %{
          log_entry: line,
          metadata: metadata
        }
      end)

    body =
      Jason.encode!(%{
        source: source,
        batch: batch
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
