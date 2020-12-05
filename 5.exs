defmodule DayFive do
  def part_one(seats) do
    seat_ids = Enum.map(seats, &determine_seat_id(&1))
    Enum.max(seat_ids)
  end
  def part_two(seats) do
    seat_ids = Enum.map(seats, &determine_seat_id(&1))
    max_seat_id = part_one(seats)

    missing_seats = Enum.filter(
      Enum.to_list(0..round(max_seat_id)),
      fn potential_seat_id -> not Enum.member?(seat_ids, potential_seat_id) end
    )

    Enum.filter(
      missing_seats,
      fn missing_seat -> Enum.member?(seat_ids, missing_seat + 1) and Enum.member?(seat_ids, missing_seat - 1) end
    )
  end
  def determine_seat_id(seat_string) do
    row_string = String.slice(seat_string, 0..6)
    row = parse_partition_string(row_string, 0, 127)
    col_string = String.slice(seat_string, 7..-1)
    column = parse_partition_string(col_string, 0, 7)
    round(row * 8 + column)
  end

  def parse_partition_string(row_string, lower_bound, upper_bound) when row_string !== "" do
    next_char = String.at(row_string, 0)
    case next_char do
      n when n in ["F", "L"] -> parse_partition_string(
        String.slice(row_string, 1..-1),
        lower_bound,
        lower_bound + Float.floor((upper_bound - lower_bound) / 2)
      )
      n when n in ["B", "R"] -> parse_partition_string(
        String.slice(row_string, 1..-1),
        lower_bound + Float.ceil((upper_bound - lower_bound) / 2),
        upper_bound
      )
    end
  end

  def parse_partition_string(row_string, lower_bound, _upper_bound) when row_string === "" do
    lower_bound
  end
end

DayFive.determine_seat_id("BFFFBBFRRR")


#=> Part 1 Testing
# input = ReadInput.string_list(Path.join("inputs", "4_test.txt"))
# values = DayFive.part_one(input)
# IO.inspect values
#
# #=> Part 1
input = ReadInput.string_list(Path.join("inputs", "5.txt"))
values = DayFive.part_one(input)
IO.inspect values

input = ReadInput.string_list(Path.join("inputs", "5.txt"))
values = DayFive.part_two(input)
IO.inspect values

#=> Part 2 Testing
# input = ReadInput.string_list(Path.join("inputs", "4_test.txt"))
# values = DayFive.part_two(input)
# IO.inspect values
#
# #=> Part 2 Testing
# input = ReadInput.string_list(Path.join("inputs", "4_test_2.txt"))
# values = DayFive.part_two(input)
# IO.inspect values
#
# # #=> Part 2
# input = ReadInput.string_list(Path.join("inputs", "4.txt"))
# values = DayFive.part_two(input)
# IO.inspect values
#
# #
# # #=> Part 1
# # input = ReadInput.string_grid(Path.join("inputs", "3.txt"))
# # values = DayFive.part_two(input)
# # IO.inspect values
