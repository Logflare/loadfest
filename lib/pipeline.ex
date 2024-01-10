defmodule Loadfest.Pipeline do
  use Broadway

  alias Broadway.Message
  require Logger
  @source_names Application.get_env(:loadfest, :source_names)
  @max_rps Application.get_env(:loadfest, :max_rps, 100_000)
  defmodule Producer do
    use GenStage

    def start_link(number) do
      GenStage.start_link(__MODULE__, [])
    end

    def init(_) do
      {:producer, :ok}
    end

    def handle_demand(demand, state) when demand > 0 do
      messages = for _i <- 1..demand do
          %Broadway.Message{data: Loadfest.Worker.make_batch(250), acknowledger: {__MODULE__, :ack, 3}}
      end

      {:noreply, messages, state}
    end

    def ack(_, _, _) do
      :ok
    end
  end

  def start_link(_opts) do
    Logger.info("Starting pipeline with #{4 * System.schedulers_online()} concurrency")

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Loadfest.Pipeline.Producer, []}
      ],
      processors: [
        default: [concurrency: System.schedulers_online(), max_demand: 1]
      ]
    )
  end

  def handle_message(_processor_name, message, _context) do
    name = Enum.random(@source_names)

    body = %{
      source_name: name,
      batch: message.data
    }

    rps = Loadfest.Counter.requests()

    if rps < @max_rps do
      request = Loadfest.Client.send(name, body)

      if request.status == 200 do
        Loadfest.Counter.add(length(message.data))
      end

      if request.status >= 400 do
        Logger.warning("#{request.status} | #{inspect(request.body)}")
      end
    end

    message
  end
end
