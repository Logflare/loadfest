defmodule Loadfest.FixturesTest do
  use ExUnit.Case, async: false

  alias Loadfest.Fixtures

  setup_all do
    Fixtures.load()
    :ok
  end

  describe "sources/0" do
    test "returns all expected fixture source names" do
      assert Fixtures.sources() == ~w(edge_log postgres auth_middleware realtime_log storage api_gateway_trace)
    end
  end

  describe "load/0" do
    test "loads at least one event per source" do
      for source <- Fixtures.sources() do
        event = Fixtures.random_event(source)
        assert is_map(event), "expected a map for source #{source}"
      end
    end
  end

  describe "random_event/1" do
    test "does not include timestamp field (let logflare generate it)" do
      event = Fixtures.random_event("edge_log")
      refute Map.has_key?(event, "timestamp")
    end

    test "does not include id field (let logflare generate it)" do
      event = Fixtures.random_event("edge_log")
      refute Map.has_key?(event, "id")
    end

    test "preserves realistic payload shape for edge_log" do
      event = Fixtures.random_event("edge_log")
      assert get_in(event, ["metadata", "request", "cf", "httpProtocol"])
      assert get_in(event, ["metadata", "response", "status_code"])
      assert is_binary(event["event_message"])
    end

    test "preserves realistic payload shape for postgres" do
      event = Fixtures.random_event("postgres")
      assert get_in(event, ["metadata", "parsed", "error_severity"])
      assert get_in(event, ["metadata", "host"])
    end

    test "stamps span fields for auth_middleware" do
      before_ns = System.os_time(:nanosecond)
      event = Fixtures.random_event("auth_middleware")
      after_ns = System.os_time(:nanosecond)

      assert event["start_time"] >= before_ns
      assert event["start_time"] <= after_ns
      assert event["end_time"] >= before_ns
      assert String.length(event["span_id"]) == 16
      assert String.length(event["trace_id"]) == 32
    end

    test "stamps span fields for api_gateway_trace" do
      event = Fixtures.random_event("api_gateway_trace")
      assert is_integer(event["start_time"])
      assert is_integer(event["end_time"])
      assert String.length(event["span_id"]) == 16
      assert String.length(event["trace_id"]) == 32
    end

    test "does not stamp span fields for non-span sources" do
      for source <- ~w(edge_log postgres realtime_log storage) do
        event = Fixtures.random_event(source)
        refute Map.has_key?(event, "span_id"), "#{source} should not have span_id"
        refute Map.has_key?(event, "trace_id"), "#{source} should not have trace_id"
      end
    end

    test "returns different events across calls (randomness)" do
      events = for _ <- 1..20, do: Fixtures.random_event("edge_log")
      unique_messages = events |> Enum.map(& &1["event_message"]) |> Enum.uniq()
      # edge_log has 3 fixtures with different event_messages
      assert length(unique_messages) > 1
    end
  end

  describe "pipeline source name routing" do
    test "fixture_prefix extracts known sources" do
      # Tests the private logic via public behaviour: if source matches a fixture,
      # random_event works; otherwise it would raise.
      for source <- Fixtures.sources() do
        assert %{} = Fixtures.random_event(source)
      end
    end

    test "unknown source is not in fixtures sources list" do
      refute "test.0" in Fixtures.sources()
      refute "loadfest.test.0" in Fixtures.sources()
    end
  end
end
