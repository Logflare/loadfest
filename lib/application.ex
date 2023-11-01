defmodule Loadfest.Application do
  @moduledoc """
  Starts a dynamic supervisor for LoadFest tasks.
  """
  require Logger

  use Application

  def start(_type, _args) do
    Logger.info("Starting Loadfest")

    children = [
      {Task.Supervisor, name: Loadfest.TaskSupervisor},
      :hackney_pool.child_spec(:loadfest_pool, timeout: 15_000, max_connections: 10_000),
      # {PartitionSupervisor,
      #   child_spec: Loadfest.Worker,
      #   name: Loadfest.WorkerSup
      # }
      Loadfest.Worker
    ]

    opts = [strategy: :one_for_one, name: Loadfest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
