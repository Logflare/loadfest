defmodule Loadfest.Fixtures do
  @sources ~w(edge_log postgres auth_middleware realtime_log storage api_gateway_trace)
  @span_sources ~w(auth_middleware api_gateway_trace)

  def sources, do: @sources

  def load do
    events =
      for source <- @sources, into: %{} do
        dir = Application.app_dir(:loadfest, "priv/fixtures/#{source}")

        events =
          dir
          |> File.ls!()
          |> Enum.filter(&String.ends_with?(&1, ".json"))
          |> Enum.map(fn file -> Path.join(dir, file) |> File.read!() |> Jason.decode!() end)

        {source, events}
      end

    :persistent_term.put({__MODULE__, :events}, events)
    :ok
  end

  def random_event(source) do
    :persistent_term.get({__MODULE__, :events})
    |> Map.fetch!(source)
    |> Enum.random()
    |> stamp(source)
  end

  defp stamp(event, source) do
    now_ns = System.os_time(:nanosecond)

    event
    |> Map.delete("id")
    |> Map.delete("timestamp")
    |> stamp_span(source, now_ns)
  end

  defp stamp_span(event, source, now_ns) when source in @span_sources do
    event
    |> Map.put("start_time", now_ns)
    |> Map.put("end_time", now_ns)
    |> Map.put("span_id", rand_hex(8))
    |> Map.put("trace_id", rand_hex(16))
  end

  defp stamp_span(event, _source, _now_iso), do: event

  defp rand_hex(bytes), do: :crypto.strong_rand_bytes(bytes) |> Base.encode16(case: :lower)
end
