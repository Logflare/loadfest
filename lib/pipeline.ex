defmodule Loadfest.Pipeline do
  use Broadway

  alias Broadway.Message
  require Logger
  @source_names Application.get_env(:loadfest, :source_names)
  defmodule Producer do
    use GenStage

    def start_link(number) do
      GenStage.start_link(__MODULE__, [])
    end

    def init(_) do
      {:producer, :ok}
    end

    def handle_demand(demand, state) when demand > 0 do
      events = Loadfest.Worker.make_batch()
      {:noreply, [%Broadway.Message{data: events, acknowledger: {__MODULE__, :ack, 3}}], state}
    end

    def ack(_, _, _) do
      :ok
    end
  end

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Loadfest.Pipeline.Producer, []}
      ],
      processors: [
        default: [concurrency: 50, max_demand: 1]
      ]
    )
  end

  def handle_message(_processor_name, message, _context) do
    name = Enum.random(@source_names)

    body = %{
      source_name: name,
      batch: message.data
    }

    request = Loadfest.Client.send(name, body)

    if request.status == 200 do
      Loadfest.Counter.add(length(message.data))
    end

    if request.status >= 400 do
      Logger.warning("#{request.status} | #{inspect(request.body)}")
    end

    message
  end
end
