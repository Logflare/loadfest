defmodule Loadfest.Worker do
  use GenServer
  require Logger

  def start_link(_ots) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Logger.debug("Starting up worker")
    schedule_send()

    {:ok,
     %{
       api_key: Application.get_env(:loadfest, :api_key),
       source_names: Application.get_env(:loadfest, :source_names),
       endpoint: Application.get_env(:loadfest, :endpoint)
     }}
  end

  def handle_info(:send, state) do
    Logger.debug("Sending new batch")

    for name <- state.source_names,
        num = Enum.random(0..5),
        Logger.debug("Starting child for #{name} with #{num} requests"),
        iter <- 0..num do
      Task.Supervisor.start_child(Loadfest.TaskSupervisor, fn ->
        do_send(state, :source_name, name)
      end)
    end

    schedule_send()
    {:noreply, state}
  end

  defp do_send(state, :source_name, name) do
    # batch size
    n = Enum.random(0..100)
    batch = make_batch(n)

    headers = [
      {"Content-type", "application/json"},
      {"X-API-KEY", state.api_key},
      {"User-Agent", "Loadfest"}
    ]

    body =
      Jason.encode!(%{
        source_name: name,
        batch: batch
      })

    prev = System.monotonic_time()

    request =
      HTTPoison.post!("#{state.endpoint}/logs", body, headers, hackney: [pool: :loadfest_pool])

    next = System.monotonic_time()
    diff = next - prev
    response_headers = Enum.into(request.headers, %{})

    Logger.debug("#{request.status_code} | #{diff / 1_000_000}ms" |> IO.inspect())
  end

  defp schedule_send() do
    Process.send_after(self(), :send, 200)
  end

  defp make_batch(n \\ 50) do
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
end
