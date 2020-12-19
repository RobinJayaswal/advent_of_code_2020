defmodule DaySeventeen do
  def part_one(initial_state) do
    state = [initial_state]
    final_state = perform_cycles(state, 6)
    count_active_cubes(final_state)
  end

  def part_two() do
  end

  def perform_cycles(state, cycles) when cycles > 0 do
    updated_state = perform_cycle(state)
    perform_cycles(updated_state, cycles - 1)
  end

  def perform_cycles(state, 0) do
    state
  end

  def count_active_cubes(state) do
    flattened = Enum.flat_map(state, &Enum.flat_map(&1, fn x -> x end))
    active = Enum.filter(flattened, fn x -> x === "#" end)
    length active
  end

  #=> Represent as an array of arrays of arrays
  def perform_cycle(state) do
    sample_layer = Enum.at(state, 0)
    sample_row = Enum.at(sample_layer, 0)
    zero_layer = Enum.map(1..(length sample_layer), fn _ ->
      Enum.map(1..(length sample_row), fn _ -> "." end)
    end)

    expanded_state = Enum.map([zero_layer] ++ state ++ [zero_layer], fn layer ->
      sample_row = Enum.at(layer, 0)
      zero_row = Enum.map(1..(length sample_row), fn _ -> "." end)
      Enum.map([zero_row] ++ layer ++ [zero_row], fn row ->
        ["."] ++ row ++ ["."]
      end)
    end)

    Enum.map(
      Enum.with_index(expanded_state),
      &update_layer(&1, [], expanded_state)
    )
  end

  #=> We'll rewrite all of these updates into one single one that's recursive,
  #=> and the case where we reach a non-array is the base case
  #=> Then above, we just need to make perform_cycle dimension agnostic, and
  #=> have part 2 pass in an object with an extra dimension

  def update_layer({ layer, z_index }, other_coordinates, original_state) do
    Enum.map(
      Enum.with_index(layer),
      &update_row(&1, [z_index | other_coordinates], original_state)
    )
  end

  def update_row({ row, y_index }, other_coordinates, original_state) do
    Enum.map(
      Enum.with_index(row),
      &update_value(&1, [y_index | other_coordinates], original_state)
    )
  end

  def update_value({ value, x_index }, other_coordinates, original_state) do
    { max_dimensions_reversed, _ } = Enum.map_reduce(
      Enum.reverse([x_index | other_coordinates]),
      original_state,
      fn _, current_level ->
        { (length current_level) - 1, Enum.at(current_level, 0) }
      end
    )
    max_dimensions = Enum.reverse(max_dimensions_reversed)
    active_neighbor_indices = Enum.filter(
      generate_neighbor_indices([x_index | other_coordinates ], true),
      fn neighbor_coordinates ->
        out_of_range = Enum.any?(
          Enum.with_index(neighbor_coordinates),
          fn { coordinate, index } ->
            coordinate < 0 or coordinate > Enum.at(max_dimensions, index)
          end
        )

        case out_of_range do
          false -> get_point(original_state, neighbor_coordinates) === "#"
          _ -> false
        end
      end
    )

    num_active_neighbors = length active_neighbor_indices

    case value do
      "#" -> update_active_cube(num_active_neighbors)
      "." -> update_inactive_cube(num_active_neighbors)
    end
  end

  def update_active_cube(num_active_neighbors) do
    case num_active_neighbors do
      2 -> "#"
      3 -> "#"
      _ -> "."
    end
  end

  def update_inactive_cube(num_active_neighbors) do
    case num_active_neighbors do
      3 -> "#"
      _ -> "."
    end
  end

  def get_point(state, coordinates) do
    Enum.reduce(
      Enum.reverse(coordinates),
      state,
      fn coordinate, state_level -> Enum.at(state_level, coordinate) end
    )
  end

  def generate_neighbor_indices([first_coord | rest_coord], top_level?) do
    neighbors_on_current_dim = [first_coord - 1, first_coord, first_coord + 1]
    neighbors_in_rest_of_coords = generate_neighbor_indices(rest_coord, false)
    neighbors = Enum.flat_map(neighbors_on_current_dim, fn d_coord ->
      Enum.map(neighbors_in_rest_of_coords, fn neighbor -> [d_coord | neighbor] end)
    end)

    case top_level? do
      true -> Enum.filter(neighbors, fn neighbor -> neighbor != [first_coord | rest_coord] end)
      false -> neighbors
    end
  end

  def generate_neighbor_indices([], _) do
    [[]]
  end

  #=> One tricky thing is that you have to catch those outside the existing universe too.
  #=> At the start of every turn, let's add an empty layer in each direction
end

test_input = ReadInput.string_grid(Path.join("inputs", "17_test.txt"))
real_input = ReadInput.string_grid(Path.join("inputs", "17.txt"))


#=> Part 1 Testing
values = DaySeventeen.part_one(test_input)
IO.inspect values

values = DaySeventeen.part_one(real_input)
IO.inspect values

# values = DaySeventeen.part_two(test_input)
# IO.inspect values

# values = DaySeventeen.part_two(real_input)
# IO.inspect values
