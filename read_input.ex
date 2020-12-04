defmodule ReadInput do
  def string_list(filename) do
    {:ok, str} = File.read(filename)
    items = String.split(str, "\n")
    case Enum.at(items, (length items) - 1) do
      "" -> Enum.take(items, (length items) - 1)
      _ -> items
    end
  end

  def float_list(filename) do
    numbers = string_list(filename)
    convert_strings_to_floats(numbers)
  end

  def string_grid(filename) do
    lines = string_list(filename)
    convert_strings_to_lists(lines)
  end

  defp convert_strings_to_floats([head | tail]) do
    parse_result = Float.parse(head)
    case parse_result do
      {float_val, _} -> [float_val | convert_strings_to_floats(tail)]
      _ -> convert_strings_to_floats(tail)
    end
  end


  #=> Function header catches the empty array base case of recursive function
  defp convert_strings_to_floats([]) do
    []
  end

  defp convert_strings_to_lists([head|tail]) do
    [String.graphemes(head) | convert_strings_to_lists(tail)]
  end

  defp convert_strings_to_lists([]) do
    []
  end
end
