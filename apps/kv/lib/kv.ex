defmodule KV do
  use Application

  def start(_type, _args) do
    # Adding a name to the supervisor might be useful for debugging.
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end
