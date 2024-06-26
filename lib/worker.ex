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

  def make_batch(n \\ 50, text \\ "") do
#     message = """
#     Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus non condimentum mauris. Cras dapibus eget purus nec lacinia. Nam aliquam laoreet libero, non posuere ligula luctus eget. Sed et magna in leo tincidunt aliquam. Donec ac hendrerit risus. Aliquam id dolor gravida, laoreet erat eget, maximus nibh. Aliquam facilisis diam ipsum, at iaculis mi rutrum eu.

# Proin arcu mi, aliquam sit amet augue sit amet, efficitur vulputate metus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nam sit amet diam urna. Nullam bibendum malesuada dui vel ultrices. Etiam tempus, diam eu accumsan dictum, arcu lorem hendrerit est, at egestas nisi lorem sit amet ligula. Fusce euismod, mi sit amet luctus posuere, metus ligula fringilla risus, nec egestas magna justo sed mi. Donec vehicula velit purus, ut tincidunt lacus facilisis in.

# Donec quis tortor ut tortor lacinia egestas sit amet vitae augue. Morbi vitae diam nulla. Donec vulputate ante tortor, a auctor felis efficitur eu. Sed iaculis blandit arcu quis ultricies. Quisque dictum ex velit, id feugiat purus pellentesque nec. Vestibulum vel lacus et mauris aliquet placerat. Nunc sodales luctus sem, a consectetur lorem.

# Curabitur vestibulum arcu eu ipsum pulvinar tincidunt. Pellentesque in massa sed tellus elementum ullamcorper. Curabitur eget diam eu neque finibus tempus. Praesent ultrices, purus sed laoreet sagittis, risus justo maximus mi, lacinia facilisis metus massa ut velit. Sed at sapien ut mi gravida volutpat. Mauris leo sem, egestas vel metus et, pretium condimentum urna. Quisque eu pellentesque nulla, id dapibus dolor.

# Nulla pharetra tincidunt venenatis. Mauris ut ante mi. Morbi hendrerit ex augue, in venenatis lacus ornare in. Vestibulum sagittis molestie turpis, nec volutpat justo euismod et. Interdum et malesuada fames ac ante ipsum primis in faucibus. Aenean porta efficitur luctus. Etiam venenatis tincidunt posuere. Vivamus congue, massa a congue venenatis, odio tortor volutpat nisl, non varius leo ex sed ligula. Curabitur varius tortor et commodo vulputate. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nullam cursus dictum mi eu tristique. Duis cursus molestie tristique. Maecenas quis justo nec elit venenatis consectetur. Donec quis ipsum sit amet dui tincidunt vulputate vitae at arcu.
#     """
#     |> String.duplicate(15)

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

    batch = for _ <- 0..n do
      %{
        message: "batch size is #{n} #{text}",
        # message: "batch size is #{n} | #{message}",
        metadata: metadata
      }
    end
  end

  def stream_batch_sizes() do
    StreamData.frequency([
      {8, StreamData.constant(1)},
      {2, StreamData.integer(1..10)},
      {2, StreamData.integer(50..60)},
      {1, StreamData.integer(80..100)},
      {3, StreamData.integer(100..150)},
      {1, StreamData.integer(150..250)}
    ])
  end

  def stream_batch() do
    StreamData.fixed_map(%{
      context:
        StreamData.fixed_map(%{
          tags: StreamData.list_of(gen_string(), max_length: 50),
          value: StreamData.integer(),
          property_a: gen_string(),
          property_b: gen_string(),
          property_c: gen_string(),
          property_d: gen_string(),
          property_e: gen_string(),
          property_f: gen_string(),
          property_g: gen_string(),
          generated:
            StreamData.map_of(StreamData.integer(1..100), gen_string(),
              min_length: 5,
              max_length: 10
            ),
          nested:
            StreamData.fixed_map(%{
              property_a: gen_string(),
              property_b: gen_string(),
              property_c: gen_string(),
              property_d: gen_string(),
              property_e: gen_string(),
              property_f: gen_string(),
              property_g: gen_string(),
              nested_twice:
                StreamData.optional_map(%{
                  property_a: gen_string(),
                  property_b: gen_string(),
                  property_c: gen_string(),
                  property_d: gen_string(),
                  property_e: gen_string(),
                  property_f: gen_string(),
                  property_g: gen_string()
                })
            })
        }),
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
