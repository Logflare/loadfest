defmodule LoadfestTest do
  use ExUnit.Case, async: false
  alias Loadfest.Worker

  @tag :benchmark
  test "benchmark fibonacci list generation" do
    # capture benchee output to run assertions
    output =
      Benchee.run(%{
        "20_basic" => fn ->
          Worker.make_batch(20)
        end,
        "20_stream" => fn ->
          Worker.stream_batch(20)
        end
      })

    results = Enum.at(output.scenarios, 0)
    assert results.run_time_data.statistics.average <= 50_000_000
  end
end
