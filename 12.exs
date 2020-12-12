defmodule DayTwelve do
  def part_one(instructions) do
    instructions = parse_instructions(instructions)
    { { x, y }, _d } = part_one_carry_out_instructions(instructions)
    manhattan_dist({ 0, 0 }, { x, y })
  end

  def part_two(instructions) do
    instructions = parse_instructions(instructions)
    { { x, y }, _d } = part_two_carry_out_instructions(instructions)
    manhattan_dist({ 0, 0 }, { x, y })
  end

  def manhattan_dist({ x1, y1 }, { x2, y2 }) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def parse_instructions(instructions) do
    parsed = Enum.map(instructions, fn x -> Regex.run(~r/([N | S | E | W | L | R | F])([0-9]+)/, x) end)
    Enum.map(parsed, fn [_, action, value] -> { action, elem(Integer.parse(value), 0) } end)
  end

  def part_one_carry_out_instructions(instructions) do
    initial_state = { 0, 0 }
    initial_direction = "E"

    Enum.reduce(
      instructions,
      { initial_state, initial_direction },
      &part_one_handle_instruction(&1, &2)
    )
  end

  def part_one_handle_instruction({ action, value }, { { x, y }, direction }) do
    case action do
      "N" -> { { x, y + value }, direction }
      "S" -> { { x, y - value }, direction }
      "E" -> { { x + value, y }, direction }
      "W" -> { { x - value, y }, direction }
      "F" -> part_one_handle_instruction({ direction, value }, { { x, y }, direction })
      "R" -> { { x, y }, handle_right_turn(direction, value )}
      "L" -> { { x, y }, handle_left_turn(direction, value )}
    end
  end

  def part_two_carry_out_instructions(instructions) do
    initial_state = { 0, 0 }
    initial_waypoint = { 10, 1 }

    Enum.reduce(
      instructions,
      { initial_state, initial_waypoint },
      &part_two_handle_instruction(&1, &2)
    )
  end

  def part_two_handle_instruction({ action, value }, { { x, y }, { x_d, y_d } }) do
    case action do
      "N" -> { { x, y }, { x_d, y_d + value } }
      "S" -> { { x, y }, { x_d, y_d - value } }
      "E" -> { { x, y }, { x_d + value, y_d } }
      "W" -> { { x, y }, { x_d - value, y_d } }
      "F" -> { { x + value * x_d, y + value * y_d }, { x_d, y_d }}
      "R" -> { { x, y }, update_waypoint({ x_d, y_d }, :right, value )}
      "L" -> { { x, y }, update_waypoint({ x_d, y_d }, :left, value )}
    end
  end

  def update_waypoint({ wayp_x, wayp_y }, direction, degrees) do
    rotations = round(rem(degrees, 360) / 90)
    Enum.reduce(1..rotations, { wayp_x, wayp_y }, fn _, { acc_x, acc_y } ->
      case direction do
        :right -> { acc_y, -1 * acc_x }
        :left -> { -1 * acc_y, acc_x }
      end

    end)
  end

  def handle_right_turn(current_direction, degrees) do
    handle_turn(current_direction, degrees, ["N", "E", "S", "W"])
  end

  def handle_left_turn(current_direction, degrees) do
    handle_turn(current_direction, degrees, Enum.reverse(["N", "E", "S", "W"]))
  end

  def handle_turn(current_direction, degrees, direction_order) do
    current_ind = Enum.find_index(direction_order, fn x -> x === current_direction end)
    case rem(degrees, 360) do
      0 -> current_direction
      90 -> Enum.at(direction_order, rem( current_ind + 1, (length direction_order) ))
      180 -> Enum.at(direction_order, rem( current_ind + 2, (length direction_order) ))
      270 -> Enum.at(direction_order, rem( current_ind + 3, (length direction_order) ))
    end
  end
end

test_input = ReadInput.string_list(Path.join("inputs", "12_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "12.txt"))

#=> Part 1 Testing
values = DayTwelve.part_one(test_input)
IO.inspect values

values = DayTwelve.part_one(real_input)
IO.inspect values
# # #
values = DayTwelve.part_two(test_input)
IO.inspect values
# # # #
values = DayTwelve.part_two(real_input)
IO.inspect values
