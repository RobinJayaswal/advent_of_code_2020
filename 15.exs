defmodule DayFifteen do
  def part_one(starting_numbers) do
    { most_recent_number, _ } = play_game_till_turn(starting_numbers, 2020)
    most_recent_number
  end

  def part_two(starting_numbers) do
    { most_recent_number, _ } = play_game_till_turn(starting_numbers, 30000000)
    most_recent_number
  end

  def play_game_till_turn(starting_numbers, turn_to_stop) do
    initial_last_seen_map = Enum.reduce(
      Enum.with_index(Enum.slice(starting_numbers, 0..-1)),
      %{},
      fn { number, index }, last_seen_map ->
        Map.put(last_seen_map, number, index)
      end
    )
    starting_turn = length starting_numbers
    initial_prev = Enum.at(initial_last_seen_map, -1)
    Enum.reduce(
      starting_turn..(turn_to_stop - 1),
      { initial_prev, initial_last_seen_map },
      fn turn, { prev_number, last_seen_map } ->
        case last_seen_map[prev_number] do
          nil -> { 0, Map.put(last_seen_map, prev_number, turn - 1) }
          x -> { turn - 1 - x, Map.put(last_seen_map, prev_number, turn - 1) }
        end
      end
    )
  end

  # 3 to 4
  # 3: 6, this shouldnt be in the map. Returns 0 and new map
  # 4: 0, this is in the map. Says 4 - 1 - 0 = 3

end

test_input = [0,3,6]
real_input = [9,6,0,10,18,2,1]

#=> Part 1 Testing
# values = DayFifteen.part_one(test_input)
# IO.inspect values
# #
# values = DayFifteen.part_one(real_input)
# IO.inspect values
# # # # #
# values = DayFifteen.part_two(test_input)
# IO.inspect values
# # # # # #
values = DayFifteen.part_two(real_input)
IO.inspect values
