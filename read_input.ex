defmodule ReadInput do
  def float_list(filename) do
    {:ok, number_str} = File.read(filename)
    numbers = String.split(number_str, "\n")
    convert_strings_to_floats(numbers)
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
end
