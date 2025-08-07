defmodule Lab.Slow do
  # Simulates a 1-second task
  def run(item) do
    :timer.sleep(1000) # Sleep for 1000 milliseconds
    IO.puts "Processed #{item}"
  end
end
