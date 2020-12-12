defmodule DayNine do
  def part_one(numbers, preamble_length) do
    find_bad_numbers(numbers, preamble_length)
  end

  def part_two(numbers, preamble_length) do
    [bad_number | _] = part_one(numbers, preamble_length)
    series = find_contiguous_numbers_summing_to(numbers, bad_number)
    { min, max } = Enum.min_max(series)
    min + max
  end

  def find_bad_numbers(numbers, preamble_length) do
    preamble = Enum.take(numbers, preamble_length)
    rest = Enum.take(numbers, preamble_length - (length numbers))

    { _, bad_numbers } = Enum.reduce(rest, { preamble, [] }, fn number, { prev_n, bad_numbers } ->
      #=> Check if two (unique) numbers in prev_n sum to number.
      #=> If not, add to bad_numbers
      pairs = Enum.flat_map(
        Enum.with_index(prev_n),
        fn { n, index } ->
          Enum.map(
            Enum.slice(prev_n, index..-1),
            fn n2 -> { n, n2 } end
          )
        end
      )

      pairs = Enum.filter(pairs, fn { val1, val2 } -> val1 !== val2 end)
      sums = Enum.map(pairs, fn { x, y } -> x + y end)
      case Enum.member?(sums, number) do
        true -> { shift_prev_n(prev_n, number), bad_numbers }
        false -> { shift_prev_n(prev_n, number), bad_numbers ++ [number] }
      end
    end)

    bad_numbers
  end

  def shift_prev_n(prev_n, number) do
    Enum.slice(prev_n, 1..-1) ++ [number]
  end

  def find_contiguous_numbers_summing_to([jump_off | rest], target) do
    #=> Recursive function that
    sequence = check_if_jump_off_point_gives_sum([jump_off | rest], [], target)
    case sequence do
      nil -> find_contiguous_numbers_summing_to(rest, target)
      x -> x
    end
  end

  def find_contiguous_numbers_summing_to([], _) do
    nil
  end

  def check_if_jump_off_point_gives_sum([next_num | rest], sequence, target) do
    new_sequence = sequence ++ [next_num]
    case Enum.sum(new_sequence) do
      x when x === target -> new_sequence
      x when x > target -> nil
      _ -> check_if_jump_off_point_gives_sum(rest, new_sequence, target)
    end
  end

  def check_if_jump_off_point_gives_sum([], _s, _t) do
    nil
  end

end

test_input = ReadInput.int_list(Path.join("inputs", "9_test.txt"))
real_input = ReadInput.int_list(Path.join("inputs", "9.txt"))

#=> Part 1 Testing
values = DayNine.part_one(test_input, 5)
IO.inspect values

values = DayNine.part_one(real_input, 25)
IO.inspect values
# #
values = DayNine.part_two(test_input, 5)
IO.inspect values
# # #
values = DayNine.part_two(real_input, 25)
IO.inspect values
