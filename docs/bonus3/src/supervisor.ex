# Lets make the namespace a child of `Lab.Counter` for clarity.
defmodule Lab.Counter.Supervisor do
  use Supervisor

  def start_link, do: start_link(0)
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    children = [
      # Define the child process to be supervised.
      # If this process dies, the supervisor will restart it.
      {Lab.Counter, init_arg} # {Module, initial_state}
    ]

    # The :one_for_one strategy means if a child dies, only that child is restarted.
    # This is only one of many strategies supervisors can use.
    Supervisor.init(children, strategy: :one_for_one)
  end
end
