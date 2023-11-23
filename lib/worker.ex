defmodule Loadfest.Worker do
  use GenServer
  require Logger

  def start_link(_ots) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Logger.debug("Starting up worker")
    send(self(), :work)

    {:ok,
     %{
       api_key: Application.get_env(:loadfest, :api_key),
       source_names: Application.get_env(:loadfest, :source_names),
       endpoint: Application.get_env(:loadfest, :endpoint)
     }}
  end

  def handle_info(:work, state) do
    batch_stream = make_batch_stream()

    Task.Supervisor.async_stream(Loadfest.TaskSupervisor, batch_stream, fn batch ->
      name = Enum.random(state.source_names)
      :telemetry.execute([:loadfest, :send], %{name: name, batch_size: length(batch)})
      do_send(state, :source_name, name, batch)
    end)
    |> Enum.to_list()

    send(self(), :work)
    {:noreply, state}
  end

  defp do_send(state, :source_name, name, batch) do
    # batch size
    headers = [
      {"Content-type", "application/json"},
      {"X-API-KEY", state.api_key},
      {"User-Agent", "Loadfest"}
    ]

    body = %{
      source_name: name,
      batch: batch
    }

    prev = System.monotonic_time()

    request = Loadfest.Client.send(name, body)
    next = System.monotonic_time()
    diff = next - prev

    if request.status == 200 do
      Loadfest.Counter.add(length(batch))
    end

    if request.status >= 400 do
      Logger.warning("#{request.status} | #{inspect(request.body)}")
    end
  end

  defp schedule_send() do
    Process.send_after(self(), :send, 200)
  end

  def make_batch(n \\ 50) do
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
      0..n
      |> Enum.map(fn _x ->
        %{
          message: "batch size is #{n}",
          metadata: metadata
        }
      end)
  end

  def stream_batch() do
    StreamData.optional_map(%{
      custom_user_data:
        StreamData.optional_map(%{
          address:
            StreamData.optional_map(%{
              city: gen_string(),
              st: gen_string(),
              street: gen_string(),
              zip: gen_string()
            }),
          company: gen_string(),
          id: StreamData.integer(),
          login_count: StreamData.integer(),
          vip: StreamData.boolean()
        }),
      datacenter: gen_string(),
      ip_address: gen_string(),
      request_headers:
        StreamData.optional_map(%{connection: gen_string(), user_agent: gen_string()}),
      request_method: gen_string()
    })
  end

  def make_batch_stream() do
    StreamData.list_of(stream_batch(), min_length: 20, max_length: 100)
  end

  defp gen_string, do: StreamData.string(:alphanumeric, min_length: 2, max_length: 20)
end
