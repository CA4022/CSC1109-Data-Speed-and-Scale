defmodule Lab.Counter do
  use GenServer

  # --- Client API ---
  # These are the public functions users will call.

  def start_link, do: start_link(0)
  def start_link(initial_value) do
    # Spawns and links the GenServer process, calling our init/1 callback.
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def read() do
    # Sends a synchronous message and waits for a reply.
    GenServer.call(__MODULE__, :read)
  end

  def increment() do
    # Sends an asynchronous message and returns immediately.
    GenServer.cast(__MODULE__, :increment)
  end

  def crash() do
    # This deliberately causes a crash. It's here for demonstration purposes.
    # We will use this later to show how the BEAM's fault tolerance works.
    GenServer.cast(__MODULE__, :crash)
  end

  # --- Server Callbacks ---
  # These callbacks run inside the isolated GenServer process.

  @impl true # This marks a function as a callback
  def init(initial_value) do
    # Note the use of a labelled tuple here. This is common in elixir, and acts much like the
    # "Result" monad in many other languages. Instead, it uses BEAM `atoms` to signal state. These
    # structured, efficiently pattern matched messages are a key way in which the actor model
    # can be used to robustly manage interprocess messaging.
    {:ok, initial_value}
  end

  @impl true
  def handle_call(:read, _from, state) do
    # Handles synchronous 'read' calls.
    # Returns the current state to the caller.
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:increment, state) do
    # Handles asynchronous 'increment' casts.
    # The new state is state + 1.
    new_state = state + 1
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:crash, _state) do
    # If we get a pattern with the `:crash` method, do as we're told!
    raise "Boom! (I was told to crash)"
  end
end
