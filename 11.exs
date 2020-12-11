defmodule DayEleven do
  def part_one(seat_layout) do
    stable_state = simulate_rounds_until_stable(
      seat_layout,
      &directly_adjacent_visibility_func(&1, &2)
    )
    count_occupied_seats(stable_state)
  end
  def part_two(seat_layout) do
    stable_state = simulate_rounds_until_stable(
      seat_layout,
      &line_of_sight_vis_func(&1, &2)
    )
    count_occupied_seats(stable_state)
  end

  def count_occupied_seats(layout) do
    Enum.reduce(layout, 0, fn row, acc ->
      acc + Enum.count(row, fn x -> x === "#" end)
    end)
  end

  def test_layout_equality(layout_x, layout_y) do
    with_row_ind_x = Enum.with_index(layout_x)
    with_row_and_col_ind_x = Enum.map(with_row_ind_x, fn { row, row_index } ->
      row_with_col_ind = Enum.with_index(row)
      Enum.map(row_with_col_ind, fn { el, col_index } -> { el, row_index, col_index } end)
    end)

    Enum.all?(with_row_and_col_ind_x, fn row_x ->
      Enum.all?(row_x, fn { el, row_index, col_index } ->
        el === Enum.at(Enum.at(layout_y, row_index), col_index)
      end)
    end)
  end

  def simulate_rounds_until_stable(seat_layout, visibility_func) do
    new_seat_layout = simulate_round(seat_layout, visibility_func)
    case test_layout_equality(seat_layout, new_seat_layout) do
      true -> new_seat_layout
      false -> simulate_rounds_until_stable(new_seat_layout, visibility_func)
    end
  end

  def simulate_round(seat_layout, visibility_func) do
    with_row_ind = Enum.with_index(seat_layout)
    with_row_and_col_ind = Enum.map(with_row_ind, fn { row, row_index } ->
      row_with_col_ind = Enum.with_index(row)
      Enum.map(row_with_col_ind, fn { el, col_index } -> { el, row_index, col_index } end)
    end)
    Enum.map(
      with_row_and_col_ind,
      fn row -> Enum.map(row, fn params -> visibility_func.(seat_layout, params) end)
    end
    )
  end

  def directly_adjacent_visibility_func(seat_layout, { el, row_index, col_index }) do
    adjacent_indices = Enum.filter(
      [
        { row_index - 1, col_index - 1 },
        { row_index - 1, col_index },
        { row_index - 1, col_index + 1},
        { row_index, col_index - 1},
        { row_index, col_index + 1},
        { row_index + 1, col_index - 1 },
        { row_index + 1, col_index },
        { row_index + 1, col_index + 1 },
      ], fn { adj_row, adj_col } ->
        adj_row >= 0 and adj_row < (length seat_layout) and adj_col >= 0 and adj_col < (length Enum.at(seat_layout, 0))
      end
    )


    occupied_adj = Enum.filter(adjacent_indices, fn { adj_row, adj_col } ->
      Enum.at(Enum.at(seat_layout, adj_row), adj_col) === "#"
    end)

    cond do
      el === "." -> "."
      (length occupied_adj) >= 4 -> "L"
      el === "L" and (length occupied_adj) === 0 -> "#"
      true -> el
    end
  end

  def line_of_sight_vis_func(seat_layout, { el, row_index, col_index }) do
    lines_of_sight = [
      { -1, - 1 },
      { -1, 0 },
      { -1, + 1},
      { 0, - 1},
      { 0, + 1},
      { +1, - 1 },
      { +1, 0 },
      { +1, + 1 },
    ]

    occupied_in_lines_of_sight = Enum.filter(lines_of_sight, fn { row_delta, col_delta } ->
      next_seat = find_next_seat_on_line_of_sight(
        seat_layout,
        row_index,
        col_index,
        row_delta,
        col_delta
      )
      next_seat === "#"
    end)

    cond do
      el === "." -> "."
      (length occupied_in_lines_of_sight) >= 5 -> "L"
      el === "L" and (length occupied_in_lines_of_sight) === 0 -> "#"
      true -> el
    end
  end

  def find_next_seat_on_line_of_sight(seat_layout, row_index, col_index, row_delta, col_delta) do
    next_row = row_index + row_delta
    next_col = col_index + col_delta

    case spot_at_row_col(seat_layout, next_row, next_col) do
      nil -> nil
      "." -> find_next_seat_on_line_of_sight(seat_layout, next_row, next_col, row_delta, col_delta)
      x -> x
    end
  end

  def spot_at_row_col(seat_layout, row, col) do
    cond do
      row < 0 or row > (length seat_layout) - 1 -> nil
      col < 0 or col > (length Enum.at(seat_layout, 0)) - 1 -> nil
      true -> Enum.at(Enum.at(seat_layout, row), col)
    end
  end
end

test_input = ReadInput.string_grid(Path.join("inputs", "11_test.txt"))
real_input = ReadInput.string_grid(Path.join("inputs", "11.txt"))

#=> Part 1 Testing
values = DayEleven.part_one(test_input)
IO.inspect values

# values = DayEleven.part_one(real_input)
# IO.inspect values
# #
values = DayEleven.part_two(test_input)
IO.inspect values
# #
values = DayEleven.part_two(real_input)
IO.inspect values
