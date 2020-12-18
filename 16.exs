defmodule DaySixteen do
  def part_one(info) do
    {
      fields,
      your_ticket,
      nearby_tickets
    } = parse_info(info)
    invalid_tickets = identify_invalid_tickets(nearby_tickets, fields)
    sum_invalid_values(Enum.filter(invalid_tickets, fn { _, is_invalid, _} -> is_invalid end))
  end

  def part_two(info) do
    {
      fields,
      your_ticket,
      nearby_tickets
    } = parse_info(info)
    tickets_with_invalid = identify_invalid_tickets(nearby_tickets, fields)
    valid_tickets = Enum.filter(tickets_with_invalid, fn { _, is_invalid, _} -> not is_invalid end)
    valid_tickets = Enum.map(valid_tickets, fn { values, _, _ } -> values end)
    field_order = determine_field_order(your_ticket, fields, valid_tickets)
    Enum.reduce(Enum.with_index(field_order), %{}, fn { field, index }, ticket ->
      Map.put(ticket, field, Enum.at(your_ticket, index))
    end)
  end

  def identify_invalid_tickets(tickets, fields) do
    all_valid_values = Enum.reduce(fields, [], fn { _, ranges }, values ->
      Enum.concat([values | ranges])
    end)
    Enum.map(tickets, fn ticket ->
      bad_values = Enum.filter(ticket, fn x -> not Enum.member?(all_valid_values, x) end)
      { ticket, (length bad_values) > 0, bad_values }
    end)
  end

  def sum_invalid_values(invalid_tickets) do
    Enum.reduce(invalid_tickets, 0, fn { _, _, bad_values }, sum ->
      Enum.sum([sum | bad_values])
    end)
  end

  def determine_field_order(your_ticket, fields, nearby_tickets) do
    #=> Cant just narrow it down and expect to get to an array of one. There is elimination
    #=> required too, aka if a column is the only one that could fit a particular column (even if
    #=> it could fit others) then we know it's that one
    #=> Maybe makes more sense to map fields to the column they could fit.
    #=> If a field could only fit one column, then we know it's that one
    #=> If any fields have one column, then we assign it to that, and delete that
    #=> column from all other fields. Then we repeat and look for the next field with only
    #=> one column.
    number_columns = ((length your_ticket) - 1)
    initial_fields_to_potential_columns = Enum.reduce(fields, %{}, fn { name, _ }, map ->
      Map.put(map, name, 0..number_columns)
    end)

    #=> First eliminate columns from the fields_to_columns map using each ticket
    fields_to_potential_columns = Enum.reduce(
      nearby_tickets,
      initial_fields_to_potential_columns,
      &update_fields_to_columns_based_on_ticket(&1, &2, fields)
    )

    #=> Then we will interpret the fields map to get an assignment (see description above)
    fields_to_columns = narrow_down_potential_columns(fields_to_potential_columns)

    ordered_fields = Enum.sort_by(Map.to_list(fields_to_columns), fn {_, [col]} -> col end)
    Enum.map(ordered_fields, fn {field, _col} -> field end)
  end

  #=> If any fields have one column, then we assign it to that, and delete that
  #=> column from all other fields. Once we've done that for all fields with only one column,
  #=> we recurse to do it again.
  #=> Base case is when: We don't remove any columns in an iteration,
  #=> aka the object does not change at all
  def narrow_down_potential_columns(fields_to_potential_columns) do
    #=> Get all fields where potential column length is one.
    single_opt_entries = Enum.filter(
      Map.to_list(fields_to_potential_columns),
      fn { _field, potential_columns } -> (length potential_columns) === 1 end
    )

    updated_f_to_pc_map = Enum.reduce(
      single_opt_entries,
      fields_to_potential_columns,
      &delete_known_column_from_other_fields(&1, &2)
    )

    #=> Base case is when map stops changing
    case Map.equal?(fields_to_potential_columns, updated_f_to_pc_map) do
      true -> updated_f_to_pc_map
      false -> narrow_down_potential_columns(updated_f_to_pc_map)
    end
  end

  def delete_known_column_from_other_fields({ field, [known_column] }, f_to_c_map) do
    other_fields = Enum.filter(Map.keys(f_to_c_map), fn x -> x !== field end)
    Enum.reduce(other_fields, f_to_c_map, fn field, map ->
      new_potential_columns = Enum.filter(map[field], fn col -> col !== known_column end)
      Map.put(map, field, new_potential_columns)
    end)
  end

  def update_fields_to_columns_based_on_ticket(ticket, starting_fields_to_columns_map, fields) do
    Enum.reduce(
      fields,
      starting_fields_to_columns_map,
      fn { name, ranges }, f_to_c_map ->
        current_potential_columns = f_to_c_map[name]
        columns_not_fitting_this_field = ticket_columns_not_in_ranges(ticket, ranges)
        new_potential_columns = Enum.filter(
          current_potential_columns,
          fn col -> not Enum.member?(columns_not_fitting_this_field, col) end
        )
        Map.put(f_to_c_map, name, new_potential_columns)
      end
    )
  end

  def ticket_columns_not_in_ranges(ticket, ranges) do
    ticket_w_ix = Enum.with_index(ticket)
    values_not_fitting_range = Enum.filter(ticket_w_ix, fn { value, _ } ->
      not Enum.any?(ranges, fn range -> Enum.member?(range, value) end)
    end)

    Enum.map(values_not_fitting_range, fn { _, ix } -> ix end)
  end

  def parse_info(info) do
    your_ticket_index = Enum.find_index(info, fn x -> String.trim(x) === "your ticket:" end)
    fields_spec_ixs = 0..(your_ticket_index - 2)
    your_ticket_info_ix = your_ticket_index + 1
    nearby_tickets_ixs = (your_ticket_index + 4)..-1

    fields = Enum.map(
      Enum.slice(info, fields_spec_ixs),
      &parse_field(&1)
    )

    your_ticket = parse_ticket(Enum.at(info, your_ticket_info_ix))

    nearby_tickets = Enum.map(
      Enum.slice(info, nearby_tickets_ixs),
      &parse_ticket(&1)
    )

    {
      fields,
      your_ticket,
      nearby_tickets
    }
  end

  def parse_ticket(ticket_line) do
    values = String.split(ticket_line, ",")
    Enum.map(values, fn x -> elem(Integer.parse(x), 0) end)
  end

  def parse_field(field_line) do
    [name, range_str] = Enum.map(String.split(field_line, ":"), &String.trim(&1))
    ranges = Enum.map(
      String.split(range_str, "or"),
      fn range ->
        [{ lower_bound, _l }, { upper_bound, _u }] = Enum.map(
          String.split(String.trim(range), "-"),
          &Integer.parse(&1)
        )
        lower_bound..upper_bound
      end
    )
    { name, ranges }
  end
end

test_input = ReadInput.string_list(Path.join("inputs", "16_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "16.txt"))

#=> Part 1 Testing
values = DaySixteen.part_one(test_input)
IO.inspect values
#
values = DaySixteen.part_one(real_input)
IO.inspect values
# # # # #
values = DaySixteen.part_two(test_input)
IO.inspect values
# # # # # #
values = DaySixteen.part_two(real_input)
IO.inspect values
