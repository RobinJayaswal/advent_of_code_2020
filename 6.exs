defmodule DaySix do
  def part_one(groups) do
    Enum.sum(
      Enum.map(groups, &number_of_unique_qs_for_group(&1))
    )
  end

  def part_two(groups) do
    Enum.sum(
      Enum.map(groups, &number_of_intersected_qs_for_group(&1))
    )
  end

  def number_of_unique_qs_for_group(group) do
    unique_qs = get_unique_qs_for_group(group)
    length unique_qs
  end

  def get_unique_qs_for_group(group) do
    all_qs_str = Enum.reduce(group, "", fn member, acc -> acc <> member end)
    Enum.uniq(String.graphemes(all_qs_str))
  end

  def number_of_intersected_qs_for_group(group) do
    intersected_qs = get_intersected_qs_for_group(group)
    length intersected_qs
  end

  def get_intersected_qs_for_group(group) do
    Enum.reduce(
      group,
      String.graphemes(Enum.at(group, 0)),
      fn member, acc -> intersect_lists(acc, String.graphemes(member)) end
    )
  end

  def intersect_lists(list_one, list_two) do
    uniq_one = Enum.uniq(list_one)
    uniq_two = Enum.uniq(list_two)
    uniq_combined = uniq_one ++ uniq_two
    count_tuples = create_el_count_tuple(uniq_combined)
    in_both = Enum.filter(count_tuples, fn { _key, count} -> count > 1 end)
    Enum.map(in_both, fn { key, _count } -> key end)
  end

  def create_el_count_tuple(list) do
    counts = Enum.reduce(
      list,
      %{},
      fn el, acc -> case acc[el] do
        nil -> Map.put(acc, el, 1)
        _ -> %{acc | el => acc[el] + 1 }
      end end
    )
    Map.to_list(counts)
  end
end

test_input = ReadInput.grouped_string_list(Path.join("inputs", "6_test.txt"))
real_input = ReadInput.grouped_string_list(Path.join("inputs", "6.txt"))

#=> Part 1 Testing
values = DaySix.part_one(test_input)
IO.inspect values

values = DaySix.part_one(real_input)
IO.inspect values

values = DaySix.part_two(test_input)
IO.inspect values

values = DaySix.part_two(real_input)
IO.inspect values
