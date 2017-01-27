defmodule MurderSupervisorTest do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Murder.Supervisor.Supervisor, []),
    ]
    opts = [strategy: :one_for_one, name: MurderSupervisorTest]
    result = Supervisor.start_link(children, opts)
    Murder.Supervisor.Supervisor.start_child(1) 
    result
  end
end
