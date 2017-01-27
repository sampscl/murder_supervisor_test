#
# Murder.Worker

defmodule Murder.Worker do
  use GenServer
  require Logger
  ##############################
  # API
  ##############################

  def start_link(n) do
    GenServer.start_link(__MODULE__, [n], [name: __MODULE__])
  end

  defmodule State do
    @doc false
    defstruct [
      porcelain_process: nil,
      n: nil,
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  def init([n]) do
    pp = PorcelainUtils.spawn_shell("tshark", "murder_worker_#{n}", :KILL)
    state = %State{porcelain_process: pp, n: n}
    Logger.info("state is #{inspect(state)}")
    Process.send_after(self(), :murder, 5_000)
    {:ok, state}
  end

  def handle_info({_porcelain_process_pid, :result, %Porcelain.Result{}}, state) do
    Logger.info("porcelain process died")
    {:noreply, %{state | porcelain_process: nil}}
  end

  def handle_info({_porcelain_process_pid, :data, :out, data}, state) do
    Logger.info("porcelain process says: #{inspect(data)}")
    {:noreply, state}
  end

  def handle_info(:murder, state) do
    Logger.info("#{__MODULE__} die #{state.n}")
    spawn(fn() -> Murder.Supervisor.die(state.n) end)
    {:noreply, state}
  end

  ##############################
  # Internal Calls
  ##############################

end
