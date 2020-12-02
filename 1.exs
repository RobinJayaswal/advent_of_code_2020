defmodule DayOne do
  #=> find the two entries that sum to `sum`. Expects floats or integers
  def find_entries_summing_to([head | tail], sum) do
    target = sum - head
    target_index = Enum.find_index(tail, fn entry -> entry == target end)

    case target_index do
      x when is_integer(x) -> [head, target]
      _ -> find_entries_summing_to(tail, sum)
    end
  end

  def find_entries_summing_to([], _) do
    nil
  end
end


input = ReadInput.float_list(Path.join("inputs", "1.txt"))
values = DayOne.find_entries_summing_to(input, 2020)
IO.inspect values, label: "The values are"
IO.puts "The product is #{Enum.reduce(values, 1, &*/2)}"
