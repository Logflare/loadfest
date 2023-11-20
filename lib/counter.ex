defmodule Loadfest.Counter do
  use GenServer
  require Logger

  def start_link(_ots) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Logger.debug("Starting up counter")
    ref = :counters.new(4, [:atomics])
    schedule()

    {:ok,
     %{
       ref: ref
     }}
  end

  def add(batch_size) do
    GenServer.cast(__MODULE__, {:add, batch_size})
  end

  def handle_cast({:add, size}, state) do
    :counters.add(state.ref, idx(:requests), 1)
    :counters.add(state.ref, idx(:events), size)
    :counters.add(state.ref, idx(:total_requests), 1)
    :counters.add(state.ref, idx(:total_events), size)
    {:noreply, state}
  end

  def handle_info(:log, state) do
    stats = %{
      requests: :counters.get(state.ref, idx(:requests)),
      events: :counters.get(state.ref, idx(:events)),
      total_requests: :counters.get(state.ref, idx(:total_requests)),
      total_events: :counters.get(state.ref, idx(:total_events))
    }

    Logger.info(inspect(stats))
    :counters.put(state.ref, idx(:requests), 0)
    :counters.put(state.ref, idx(:events), 0)
    schedule()
    {:noreply, state}
  end

  defp schedule() do
    Process.send_after(self(), :log, 1_000)
  end

  def idx(:requests), do: 1
  def idx(:events), do: 2
  def idx(:total_requests), do: 3
  def idx(:total_events), do: 4
end
