defmodule Murder.Supervisor.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def start_child(n) do
    Logger.info("#{__MODULE__} starting child")
    Supervisor.start_child(__MODULE__, [n])
  end

  def die(pid, n) do
    Logger.info("#{__MODULE__} die #{inspect(pid)}")
    Supervisor.terminate_child(__MODULE__, pid)
    start_child(n+1)
  end

  def init([]) do
    children = [
      worker(Murder.Supervisor, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
