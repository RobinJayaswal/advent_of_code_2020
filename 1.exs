defmodule DayOne do
  #=> find n entries that sum to `sum`. Expects floats or integers
  def find_n_entries_summing_to([head | tail], n, sum) do
    if n == 2 do
      find_two_entries_summing_to([head | tail], sum)
    else
      target = sum - head
      entries = find_n_entries_summing_to(tail, n - 1, target)
      case entries do
        x when is_list(x) -> [head | entries]
        _ -> find_n_entries_summing_to(tail, n, sum)
      end
    end
  end

  def find_n_entries_summing_to([], _n, _sum) do
    nil
  end

  #=> find two entries that sum to `sum`. Expects floats or integers
  def find_two_entries_summing_to([head | tail], sum) do
    target = sum - head
    target_index = Enum.find_index(tail, fn entry -> entry == target end)

    case target_index do
      x when is_integer(x) -> [head, target]
      _ -> find_two_entries_summing_to(tail, sum)
    end
  end

  def find_two_entries_summing_to([], _) do
    nil
  end

end


#=> Answer to Part 1
input = ReadInput.float_list(Path.join("inputs", "1.txt"))
values = DayOne.find_two_entries_summing_to(input, 2020)
IO.inspect values, label: "The values are"
IO.puts "The product is #{Enum.reduce(values, 1, &*/2)}"

#=> Answer to Part 2
input = ReadInput.float_list(Path.join("inputs", "1.txt"))
values = DayOne.find_n_entries_summing_to(input, 3, 2020)
IO.inspect values, label: "The values are"
IO.puts "The product is #{Enum.reduce(values, 1, &*/2)}"
