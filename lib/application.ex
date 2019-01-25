defmodule LoadFest.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {Task.Supervisor, name: LoadFest.TaskSupervisor},
      :hackney_pool.child_spec(:loadfest_pool,  [timeout: 15000, max_connections: 100])
    ]

    opts = [strategy: :one_for_one, name: LoadFest.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
