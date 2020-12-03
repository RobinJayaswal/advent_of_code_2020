defmodule DayThree do
  def part_one(grid) do
    #=> Represent the map as an array of arrays.
    #=> When the index for inner array goes past length then loop back
    count_trees_with_slope(grid, 3, 1)
  end

  def part_two(grid) do
    right_1_down_1 = count_trees_with_slope(grid, 1, 1)
    right_3_down_1 = count_trees_with_slope(grid, 3, 1)
    right_5_down_1 = count_trees_with_slope(grid, 5, 1)
    right_7_down_1 = count_trees_with_slope(grid, 7, 1)
    right_1_down_2 = count_trees_with_slope(grid, 1, 2)

    right_1_down_1 * right_3_down_1 * right_5_down_1 * right_7_down_1 * right_1_down_2
  end

  def count_trees_with_slope(grid, right_step, down_step) do
    lines_hit = Enum.map(
      Enum.filter(
        Enum.with_index(grid), fn { _line, index } -> rem(index, down_step) === 0 end
      ),
      fn { line, _index } -> line end
    )

    {points, _} = Enum.map_reduce(lines_hit, 0, fn line, x_coord -> {
      Enum.at(line, x_coord),
      rem(x_coord + right_step, length line)
    } end)

    length Enum.filter(points, fn x -> x == "#" end)
  end

end

#=> Part 1 Testing
input = ReadInput.string_grid(Path.join("inputs", "3_test.txt"))
values = DayThree.part_one(input)
IO.inspect values

#=> Part 1
input = ReadInput.string_grid(Path.join("inputs", "3.txt"))
values = DayThree.part_one(input)
IO.inspect values

#=> Part 1 Testing
input = ReadInput.string_grid(Path.join("inputs", "3_test.txt"))
values = DayThree.part_two(input)
IO.inspect values

#=> Part 1
input = ReadInput.string_grid(Path.join("inputs", "3.txt"))
values = DayThree.part_two(input)
IO.inspect values
# #=> Part 2
# input = ReadInput.string_list(Path.join("inputs", "3.txt"))
# values = DayTwo.part_two(input)
# IO.inspect values
