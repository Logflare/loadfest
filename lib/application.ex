defmodule Loadfest.Application do
  @moduledoc """
  Starts a dynamic supervisor for LoadFest tasks.
  """
  require Logger

  import Telemetry.Metrics
  use Application

  def start(_type, _args) do
    Logger.info("Starting Loadfest")

    children =
      case Application.get_env(:loadfest, :env) do
        :test ->
          [
            {Task.Supervisor, name: Loadfest.TaskSupervisor},
            :hackney_pool.child_spec(:loadfest_pool, timeout: 15_000, max_connections: 10_000),
            {Finch, name: Loadfest.Finch, size: 50_000},
          ]

        _ ->
          [
            {Task.Supervisor, name: Loadfest.TaskSupervisor},
            :hackney_pool.child_spec(:loadfest_pool, timeout: 15_000, max_connections: 10_000),
            {Finch, name: Loadfest.Finch, size: 10_000, count: 50},
            Loadfest.Worker,
            Loadfest.Counter

            # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
          ]
      end

    opts = [strategy: :one_for_one, name: Loadfest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp metrics do
    [
      summary("loadfest.send.batch_size")
    ]
  end
end
