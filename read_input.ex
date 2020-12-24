defmodule ReadInput do
  def string_list(filename) do
    str = read_file_without_trailing_newline(filename)
    String.split(str, "\n")
  end

  def grouped_string_list(filename, group_divider \\ "\n\n") do
    str = read_file_without_trailing_newline(filename)
    groups = create_string_groups(str, group_divider)
    Enum.map(groups, fn group -> String.split(group, "\n") end)
  end

  defp create_string_groups(str, group_divider) do
    groups = String.split(str, group_divider)
    case Enum.at(groups, (length groups) - 1) do
      "" -> Enum.take(groups, (length groups) - 1)
      _ -> groups
    end
  end

  def float_list(filename) do
    numbers = string_list(filename)
    convert_strings_to_floats(numbers)
  end

  def int_list(filename) do
    numbers = string_list(filename)
    Enum.map(convert_strings_to_floats(numbers), fn x -> round(x) end)
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

  def convert_strings_to_lists([head|tail]) do
    [String.graphemes(head) | convert_strings_to_lists(tail)]
  end

  def convert_strings_to_lists([]) do
    []
  end

  defp read_file_without_trailing_newline(filename) do
    {:ok, str} = File.read(filename)
    case String.at(str, -1) do
      "\n" -> String.slice(str, 0..-2)
      _ -> str
    end
  end
end
