defmodule Lab.WordCount.Supervisor do
  use DynamicSupervisor

  def start_link, do: start_link(name: Lab.WordCount.Supervisor)
  def start_link(init_arg) do
    # Start the dynamic supervisor. We give it a name so we can reference it later.
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    # Initialize the supervisor with a temporary strategy for its children.
    # This is suitable for tasks that are expected to complete and not be restarted.
    DynamicSupervisor.init(strategy: :one_for_one, temporary: true)
  end
end

defmodule Lab.WordCount do
  def count_words(input, nodes \\ [Node.self()]) do
    with {:ok, text, destination} <- parse_input(input) do
      text
      |> do_count_words(nodes)
      |> output_result(destination)
    end
  end

  defp parse_input({:file, path, destination}) do
    case File.read(path) do
      {:ok, content} -> {:ok, content, destination}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_input({:content, text, destination}) do
    {:ok, text, destination}
  end

  defp do_count_words(text, nodes) when is_binary(text) do
    text
    |> String.split(~r/[^a-zA-Z']+/, trim: true)
    |> Enum.chunk_every(128)
    |> Enum.map(&Enum.join(&1, " "))
    |> distribute_work(nodes) # The distributed "Map" phase
    |> Enum.reduce(%{}, &merge_counts/2) # The "Reduce" phase
  end

  defp output_result(word_map, :stdio) do
    IO.inspect(word_map, label: "Final Word Count")
    :ok
  end

  defp output_result(word_map, path) when is_binary(path) do
    content =
      word_map
      |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
      |> Enum.join("\n")

    File.write(path, content)
  end

  defp distribute_work(chunks, nodes) do
    chunks
    |> Enum.with_index()
    |> Enum.map(fn {chunk, index} ->
      target_node = Enum.at(nodes, rem(index, Enum.count(nodes)))
      Task.async(fn ->
        # The :rpc.call function is how we execute a function on a remote node.
        # It takes the node name, module, function, and arguments.
        :rpc.call(target_node, __MODULE__, :map_chunk, [chunk])
      end)
    end)
    |> Task.await_many(:infinity)
  end

  def map_chunk(chunk) do
    chunk
    |> String.split(~r/\s+/, trim: true)
    |> Enum.reduce(%{}, fn word, acc ->
      Map.update(acc, String.downcase(word), 1, &(&1 + 1))
    end)
  end

  defp merge_counts(new_counts, acc) do
    Map.merge(acc, new_counts, fn _word, count1, count2 ->
      count1 + count2
    end)
  end
end
