defmodule LoadFest.Application do
  @moduledoc """
  Starts a dynamic supervisor for LoadFest tasks.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {Task.Supervisor, name: LoadFest.TaskSupervisor},
      :hackney_pool.child_spec(:loadfest_pool, timeout: 15_000, max_connections: 500)
    ]

    opts = [strategy: :one_for_one, name: LoadFest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
