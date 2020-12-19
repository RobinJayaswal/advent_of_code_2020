#=> Grabbed deep flatten module from:
#=> https://gist.github.com/mareksuscak/acb4de6f72b2e6983c7c22b64bf7ce8a
defmodule Array do
  def flatten(list), do: flatten(list, [])
  def flatten([head | tail], acc) when head == [], do: flatten(tail, acc)
  def flatten([head | tail], acc) when is_list(head), do: flatten(tail, flatten(head, acc))
  def flatten([head | tail], acc), do: flatten(tail, acc ++ [head])
  def flatten([], acc), do: acc
end

defmodule DaySeventeen do
  def part_one(initial_state) do
    state = [initial_state]
    final_state = perform_cycles(state, 6)
    count_active_cubes(final_state)
  end

  def part_two(initial_state) do
    state = [[initial_state]]
    final_state = perform_cycles(state, 6)
    count_active_cubes(final_state)
  end

  def count_active_cubes(state) do
    flattened = Array.flatten(state)
    active = Enum.filter(flattened, fn x -> x === "#" end)
    length active
  end

  #=> Recursive: Complete n cycles
  def perform_cycles(state, cycles) when cycles > 0 do
    updated_state = perform_cycle(state)
    perform_cycles(updated_state, cycles - 1)
  end

  #=> Base case: All cycles completed
  def perform_cycles(state, 0), do: state


  #=> State is as an array of arrays of arrays of...
  #=> Can handle states of any dimensionality
  def perform_cycle(state) do
    expanded_state = create_expanded_state(state)

    Enum.map(
      Enum.with_index(expanded_state),
      &update_level(&1, [], expanded_state)
    )
  end

  #=> Recursive expand the state by 1 in every direction
  def create_expanded_state(state) when is_list(state) do
    sample_level = Enum.at(state, 0)
    inactive_level = create_level_of_inactives(sample_level)

    Enum.map([inactive_level] ++ state ++ [inactive_level], &create_expanded_state(&1))
  end

  #=> Base case: Reached non-list level in state, aka bottom
  def create_expanded_state(value), do: value

  #=> Recursive: Create an object with same shape as level, but all inactive
  def create_level_of_inactives(level) when is_list(level) do
    Enum.map(level, &create_level_of_inactives(&1))
  end

  #=> Base Case: Reached bottom of state. Return inactive cube
  def create_level_of_inactives(_level), do: "."

  #=> Recursive: Apply updates to a level of state. Do this by applying updates
  #=> to each element of this level of state
  def update_level(
    { level, level_coordinate }, other_coordinates, original_state
  ) when is_list(level) do
    Enum.map(
      Enum.with_index(level),
      &update_level(&1, [level_coordinate | other_coordinates], original_state)
    )
  end

  #=> Base Case: Reached bottom level of state, where level is just a value.
  #=> Update this value based on the rules
  def update_level(
    { level, level_coordinate }, other_coordinates, original_state
  ) do
    update_value({ level, level_coordinate }, other_coordinates, original_state)
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

  #=> Recursive: Generate indices of all neighbors for the set of coordinates passed in
  #=> Do this by generating all neighbors for all coordinates except the first, and
  #=> combine these with the three possible neighbor values of the first coordinate
  def generate_neighbor_indices([first_coord | rest_coord], top_level?) do
    neighbors_on_current_dim = [first_coord - 1, first_coord, first_coord + 1]
    neighbors_in_rest_of_coords = generate_neighbor_indices(rest_coord, false)
    neighbors = Enum.flat_map(neighbors_on_current_dim, fn d_coord ->
      Enum.map(neighbors_in_rest_of_coords, fn neighbor -> [d_coord | neighbor] end)
    end)

    #=> If top level function call, filter out the original point passed in.
    case top_level? do
      true -> Enum.filter(neighbors, fn neighbor -> neighbor != [first_coord | rest_coord] end)
      false -> neighbors
    end
  end

  #=> Base case: No coordinates passed in. The only 'neighbor' is just the null set
  def generate_neighbor_indices([], _) do
    [[]]
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

values = DaySeventeen.part_two(test_input)
IO.inspect values

values = DaySeventeen.part_two(real_input)
IO.inspect values
