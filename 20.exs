defmodule DayTwenty do
  def part_one(input) do
    tiles_map = parse_input(input)
    tiles_list = Map.to_list(tiles_map)
    empty_final_picture = Enum.map(1..(length tiles_list), fn _ -> nil end)

    find_valid_arrangement(Map.keys(tiles_map), empty_final_picture, 0, tiles_map)
    |> multiply_corners_of_arrangement()
  end

  def part_two(input) do

  end

  #=> ---------------------------------------
  #=> SOLUTION FORMATTING LOGIC
  #=> We have the valid arrangement, but just need to know generate the
  #=> single number that represents our answer.
  #=> ---------------------------------------
  def multiply_corners_of_arrangement(arrangement) do
    dimension = get_dimension(arrangement)
    corners = [
      placed_tile_at(arrangement, 0, 0),
      placed_tile_at(arrangement, 0, dimension - 1),
      placed_tile_at(arrangement, dimension - 1, 0),
      placed_tile_at(arrangement, dimension - 1, dimension - 1)
    ]

    corners
    |> Enum.map(fn { id, _r, _f } -> id end)
    |> Enum.reduce(1, fn id, sum -> id * sum end)

  end

  #=> ---------------------------------------
  #=> CORE LOGIC FOR FINDING ARRANGEMENT
  #=> Recursively fill each sequential part of the final square, trying each valid
  #=> possibility for filling the next square
  #=> ---------------------------------------

  #=> Flip, Rotate, and Rearrange the tiles to make them line up with each other
  #=> in a perfect square.
  #=> Tiles placed is an n x n length list of the _id, orientation, and rotation of tiles placed already.
  #=> Empty slot means no tile placed yet. We find neighbors of a position by converting index to grid position
  #=> We try to fill each position in the final array in sequence, which prunes branches much faster
  def find_valid_arrangement(unused_tiles, tiles_placed, position_to_fill, tiles_map) when length(unused_tiles) > 0 do
    #=> Map over all unused_tiles and create the valid options
    all_candidate_positions = Enum.flat_map(
      unused_tiles,
      &candidate_positions_and_orientations(&1, position_to_fill)
    )
    valid_placements = Enum.filter(
      all_candidate_positions,
      &tile_fits_with_neighbors(&1, tiles_placed, tiles_map)
    )

    case length valid_placements do
      0 -> nil
      _ -> try_valid_placements(valid_placements, unused_tiles, tiles_placed, tiles_map)
    end
  end

  def find_valid_arrangement([], tiles_placed, _p, _t), do: tiles_placed

  def try_valid_placements(valid_placements, unused_tiles, tiles_placed, tiles_map) do
    Enum.find_value(valid_placements, fn { tile_id, rotation, is_flipped, position } ->
      updated_tiles_placed = List.replace_at(tiles_placed, position, { tile_id, rotation, is_flipped })
      updated_unused_tiles = Enum.filter(unused_tiles, fn x -> x !== tile_id end)
      #=> Returns nil (falsey) when no valid arrangement possible. Else returns arrangement
      find_valid_arrangement(updated_unused_tiles, updated_tiles_placed, position + 1, tiles_map)
    end)
  end


  #=> ---------------------------------------
  #=> Generating Candidate Positions And Orientations
  #=> Based on the open slots still available on final tile, what are all the
  #=> possibilities for rotations, flipping, and position
  #=> ---------------------------------------
  def candidate_positions_and_orientations(tile_id, position) do
    rotations = [
      0, # none
      1, # 90
      2, # 180
      3, # 270
    ]

    flipped = [ true, false ]

    Enum.flat_map(
      rotations,
      fn rotation ->
        Enum.map(flipped, fn is_flipped -> { tile_id, rotation, is_flipped, position } end)
      end
    )
  end

  #=> ---------------------------------------
  #=> Neighbor Functions. Getting neighbors, checking if tile placement fits neighbors
  #=> ---------------------------------------
  def tile_fits_with_neighbors({ tile_id, rotation, is_flipped, position_index }, tiles_placed, tiles_map) do
    neighbors = get_neighbors(position_index, tiles_placed)
    tile_representation = get_tile_representation(tile_id, rotation, is_flipped, tiles_map)

    Enum.all?(
      [:top, :bottom, :left, :right],
      &tile_fits_neighbor_in_direction(&1, neighbors[&1], tile_representation, tiles_map)
    )
  end

  def get_neighbors(index, tiles_placed) do
    { row, column } = convert_index_to_row_column(index, tiles_placed)
    %{
      top: placed_tile_at(tiles_placed, row - 1, column),
      bottom: placed_tile_at(tiles_placed, row + 1, column),
      left: placed_tile_at(tiles_placed, row, column - 1),
      right: placed_tile_at(tiles_placed, row, column + 1),
    }
  end

  # => nil neighbor always matches
  def tile_fits_neighbor_in_direction(_1, neighbor, _3, _4) when neighbor === nil, do: true

  def tile_fits_neighbor_in_direction(
    direction,
    { neighbor_id, neighbor_rotation, neighbor_flipped },
    tile_representation,
    tiles_map
  ) do
    # { neighbor_id, neighbor_rotation, neighbor_flipped } = neighbors[direction]
    neighbor_tile = get_tile_representation(neighbor_id, neighbor_rotation, neighbor_flipped, tiles_map)

    case direction do
      :top -> borders_match?({ tile_representation, :top }, { neighbor_tile, :bottom })
      :bottom -> borders_match?({ tile_representation, :bottom }, { neighbor_tile, :top })
      :right -> borders_match?({ tile_representation, :right }, { neighbor_tile, :left })
      :left -> borders_match?({ tile_representation, :left }, { neighbor_tile, :right })
    end
  end

  #=> ---------------------------------------
  #=> Border Functions
  #=> ---------------------------------------
  def borders_match?({ base_tile, base_dir }, { neighbor_tile, neighbor_dir }) do
    base_border = border(base_tile, base_dir)
    neighbor_border = border(neighbor_tile, neighbor_dir)
    base_border == neighbor_border
  end

  def border(tile, :top), do: Enum.at(tile, 0)
  def border(tile, :bottom), do: Enum.at(tile, -1)
  def border(tile, :left), do: Enum.map(tile, &Enum.at(&1, 0))
  def border(tile, :right), do: Enum.map(tile, &Enum.at(&1, -1))

  #=> ---------------------------------------
  #=> Functions for Finding Tile Placed in the Tiles_Placed final array
  #=> ---------------------------------------
  def placed_tile_at(tiles_placed, row, column) do
    case convert_row_column_to_index(row, column, tiles_placed) do
      index when index < 0 -> nil
      index when index >= length tiles_placed -> nil
      index -> Enum.at(tiles_placed, index)
    end

  end

  def convert_index_to_row_column(index, list) do
    dimension = get_dimension(list)
    {Integer.floor_div(index, dimension), rem(index, dimension)}
  end

  def convert_row_column_to_index(row, column, list) do
    dimension = get_dimension(list)
    case row < 0 or row >= dimension or column < 0 or column >= dimension do
      true -> length list # give an index out of bounds
      _ -> round(row * dimension + column)
    end
  end

  def get_dimension(list), do: list |> length() |> :math.sqrt() |> round()
  #=> ---------------------------------------

  def get_tile_representation(tile_id, rotation, is_flipped, tiles_map) do
    tiles_map[tile_id]
    |> apply_rotation(rotation)
    |> apply_flip(is_flipped)
  end

  #=> ---------------------------------------
  #=> APPLYING TRANSFORMATIONS TO ORIENTATION
  #=> ---------------------------------------
  def apply_rotation(tile, rotation) do
    case rotation do
      0 -> tile
      _ -> tile |> rotate_right_90() |> apply_rotation(rotation - 1)
    end
  end

  def rotate_right_90(tile) do
    #=> The column becomes the row
    #=> (num rows) - row becomes the column
    #=> Thus in new array, at position (Row, Column)
    #=> We take what is in old tile at ((num rows) - Column, Row)
    new_row_count = length Enum.at(tile, 0)
    new_col_count = length tile
    Enum.map(0..(new_row_count - 1), fn row ->
      Enum.map(0..(new_col_count - 1), fn col ->
        tile
        |> Enum.at(length(tile) - 1 - col)
        |> Enum.at(row)
      end)
    end)
  end

  def apply_flip(tile, is_flipped) when is_flipped, do: Enum.map(tile, &Enum.reverse(&1))
  def apply_flip(tile, is_flipped) when not is_flipped, do: tile


  #=> ---------------------------------------
  #=> PARSING INPUT
  #=> ---------------------------------------
  def parse_input(input) do
    tiles = Enum.chunk_by(input, fn row -> row === "" end)
    tiles = Enum.filter(tiles, fn tile -> tile != [""] end)
    Enum.reduce(tiles, %{}, &parse_tile(&1, &2))
  end

  def parse_tile([tile_id_str | grid], tile_map), do: Map.put(tile_map, parse_tile_id(tile_id_str), ReadInput.convert_strings_to_lists(grid)) #parse_tile_grid(grid) }

  def parse_tile_id(tile_id_str) do
    with [_, id_str] <- Regex.run(~r/Tile ([0-9]+):/, tile_id_str),
         { id_int, _ } <- Integer.parse(id_str),
         do: id_int
  end

  #=> ---------------------------------------
  #=> DEBUGGING
  #=> ---------------------------------------
  def print_tile(tile) do
    Enum.map(tile, fn row -> IO.puts(Enum.join(row)) end)
    IO.puts("")
  end

  def test_from_starting_point(input) do
    tiles_map = parse_input(input)
    tiles_list = Map.to_list(tiles_map)
    placed_already = [
      {1951, 2, true},
      {2311, 2, true},
      {3079, 0, false},
      nil,
      nil,
      nil,
      nil,
      nil,
      nil
    ]

    remaining_keys = Enum.filter(Map.keys(tiles_map), fn tile ->
      not Enum.any?(Enum.filter(placed_already, fn x -> x end), fn { id, _, _ } -> tile === id end)
    end)

    find_valid_arrangement(remaining_keys, placed_already, 3, tiles_map)
  end
end

test_input = ReadInput.string_list(Path.join("inputs", "20_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "20.txt"))

# DayTwenty.test_from_starting_point(test_input)
# tile = [[0, 1, 0], [1, 1, 0], [0, 0, 0]]
# DayTwenty.print_tile(tile)
# rotated = DayTwenty.rotate_right_90(tile)
# DayTwenty.print_tile(rotated)
# flipped = DayTwenty.apply_flip(tile, true)
# DayTwenty.print_tile(flipped)

# => Part 1 Testing
values = DayTwenty.part_one(test_input)
IO.inspect values

values = DayTwenty.part_one(real_input)
IO.inspect values
#
# #=> Part 2 Testing
# values = DayTwenty.part_two(test_input)
# IO.inspect values
#
# values = DayTwenty.part_two(real_input)
# IO.inspect values
