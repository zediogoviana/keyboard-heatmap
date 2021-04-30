defmodule KeyLogParser do
  def perform(contents) do
    contents
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line(&1))
    |> Enum.reject(&is_nil(&1))
    |> Enum.frequencies()
    |> normalize_frequencies
  end

  defp parse_line(line) do
    regex = ~r"(\d+)::.+"
    match = Regex.run(regex, line)

    case match do
      [_full, matched] -> matched
      _ -> nil
    end
  end

  defp normalize_frequencies(frequencies) do
    max =
      frequencies
      |> Map.values()
      |> Enum.max()

    frequencies
    |> Enum.map(fn {k, count} -> {k, count / max} end)
    |> Enum.into(%{})
  end
end
