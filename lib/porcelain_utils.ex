defmodule PorcelainUtils do
  alias Porcelain.Result
  alias Porcelain.Process, as: Proc

  def scripts_base_dir(), do: Path.join(:code.priv_dir(:murder_supervisor_test), "scripts")

  def spawn_shell(command, pipe_id, signal) do
    # Create the pipe and wrapper command
    {erl_port, wrapper} = pipe_and_command(command, pipe_id, signal)
    # Spawn Porcelain shell
    %Proc{pid: pid} = process = Porcelain.spawn_shell(wrapper, in: :receive, out: {:send, self()}, err: :out, result: :keep)
    Process.link(pid)
    # Return Porcelain process and Erlang port to caller
    {process, erl_port}
  end

  def pipe_and_command(command, id, signal) do
    base_dir = Path.join(scripts_base_dir(), "porcelain")
    remove_named_pipe(id)
    {erl_port, named_pipe} = create_named_pipe(id)
    {erl_port, Path.join(base_dir, "start.sh #{named_pipe} #{get_signal(signal)} \"#{command}\"")}
  end

  def create_named_pipe(id) do
    # named pipe in priv porcelain dir
    named_pipe = get_named_pipe_path(id)
    # remove named pipe if exists
    case File.rm(named_pipe) do
      :ok -> :ok # File deleted
      {:error, :enoent} -> :ok # File doesn't exist
    end
    # create named pipe
    %Result{out: _output, status: _status} = Porcelain.shell("/usr/bin/mkfifo #{named_pipe}")
    # open named pipe for writing
    erl_port = :erlang.open_port(named_pipe |> String.to_charlist, [:eof])
    # return erlang port and string of location
    {erl_port, named_pipe}
  end

  def remove_named_pipe(id) do
    # remove named pipe if exists
    case get_named_pipe_path(id) |> File.rm do
      :ok -> :ok # File deleted
      {:error, :enoent} -> :ok # File doesn't exist
    end
  end

  defp get_named_pipe_path(id), do: Path.join([scripts_base_dir(), "porcelain", "pipe_#{id}"])

  defp get_signal(:HUP),    do: 1
  defp get_signal(:INT),    do: 2
  defp get_signal(:QUIT),   do: 3
  defp get_signal(:ILL),    do: 4
  defp get_signal(:TRAP),   do: 5
  defp get_signal(:ABRT),   do: 6
  defp get_signal(:BUS),    do: 7
  defp get_signal(:FPE),    do: 8
  defp get_signal(:KILL),   do: 9
  defp get_signal(:USR1),   do: 10
  defp get_signal(:SEGV),   do: 11
  defp get_signal(:USR2),   do: 12
  defp get_signal(:PIPE),   do: 13
  defp get_signal(:ALRM),   do: 14
  defp get_signal(:TERM),   do: 15
  defp get_signal(:STKFLT), do: 16
  defp get_signal(:CHLD),   do: 17
  defp get_signal(:CONT),   do: 18
  defp get_signal(:STOP),   do: 19
  defp get_signal(:TSTP),   do: 20
  defp get_signal(:TTIN),   do: 21
  defp get_signal(:TTOU),   do: 22
  defp get_signal(:URG),    do: 23
  defp get_signal(:XCPU),   do: 24
  defp get_signal(:XFSZ),   do: 25
  defp get_signal(:VTALRM), do: 26
  defp get_signal(:PROF),   do: 27
  defp get_signal(:WINCH),  do: 28
  defp get_signal(:POLL),   do: 29
  defp get_signal(:PWR),    do: 30
  defp get_signal(:SYS),    do: 31

end
