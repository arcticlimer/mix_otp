defmodule KVServer.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: KVServer.TaskSupervisor},
      Supervisor.child_spec(
        {Task, fn -> KVServer.accept(8080) end},
        restart: :permanent
      )
    ]

    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
