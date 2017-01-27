defmodule Murder.Supervisor do
  use Supervisor
  require Logger
  def start_link(n) do
    Supervisor.start_link(__MODULE__, [n], [name: __MODULE__])
  end

  def die(n) do
    Logger.info("#{__MODULE__} die #{n}")
    :gproc.lookup_pid({:n, :l, {__MODULE__, n}}) |> Murder.Supervisor.Supervisor.die(n)
  end

  def init([n]) do
    :gproc.reg({:n, :l, {__MODULE__, n}})
    Logger.info("#{__MODULE__} #{n} pid => #{inspect(self())}")
    children = [
      worker(Murder.Worker, [n], restart: :transient)
    ]
    supervise(children, strategy: :one_for_one)
  end
end
