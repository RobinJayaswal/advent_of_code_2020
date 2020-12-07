defmodule DaySeven do
  def part_one(input) do
    contained_by_map = build_container_map(input)
    containing_gold = find_all_containing_colors(contained_by_map, "shiny gold")
    length containing_gold
  end
  def part_two(input) do
    contains_map = build_contains_map(input)
    find_number_bags_contained(contains_map, "shiny gold")
  end

  def find_all_containing_colors(contained_by_map, color) do
    direct_containers = Map.get(contained_by_map, color)

    case direct_containers do
      nil -> []
      _ ->
        indirect_containers = Enum.flat_map(direct_containers, fn containing_color ->
          find_all_containing_colors(contained_by_map, containing_color)
        end)
        Enum.uniq(direct_containers ++ indirect_containers)
    end
  end

  def find_number_bags_contained(contains_map, color) do
    direct_contained = Map.get(contains_map, color)

    case length direct_contained do
      0 -> 0
      _ -> get_bag_count_for_level(contains_map, direct_contained)
    end
  end

  def get_bag_count_for_level(contains_map, direct_contained) do
    indirect_container_counts = Enum.map(direct_contained, fn { count, color } ->
      total_for_color = find_number_bags_contained(contains_map, color)
      count * total_for_color
    end)

    direct_contained_count = Enum.sum(Enum.map(direct_contained, fn { count, _ } -> count end))
    indirect_contained_count = Enum.sum(indirect_container_counts)

    direct_contained_count + indirect_contained_count
  end

  def build_container_map(rules) do
    parsed_rules = Enum.map(rules, &parse_rule(&1))
    Enum.reduce(parsed_rules, %{}, fn { color, contains }, acc ->
      #=> Loop over contains and create an update object
      contains_to_color_map = Enum.reduce(
        contains,
        %{},
        fn { _count, contain_color}, acc -> Map.put(acc, contain_color, [color]) end
      )
      Map.merge(acc, contains_to_color_map, fn _k, l1, l2 -> l1++l2 end)
    end)
  end

  def build_contains_map(rules) do
    parsed_rules = Enum.map(rules, &parse_rule(&1))
    Enum.reduce(parsed_rules, %{}, fn { color, contains }, acc ->
      #=> Loop over contains and create an update object
      Map.put(acc, color, contains)
    end)
  end

  def parse_rule(rule) do
    #=> Should look like { target, can_contain }
    [_, target, can_contain] = Regex.run(~r/(.*) bags contain (.*)\./, rule)
    can_contain_list = Enum.map(String.split(can_contain, ","), &String.trim(&1))
    can_contain_formatted = Enum.map(
      Enum.map(
        can_contain_list,
        fn x -> Regex.run(~r/([0-9]+) (.*) [bag|bags]/, x) end
      ),
      fn x -> case x do
        [_, count, color] -> { elem(Integer.parse(count), 0), color }
        _ -> nil
      end end
    )

    {
      target,
      Enum.filter(can_contain_formatted, fn x -> x !== nil end)
    }
  end
end

#=> Need to basically build a dependency graph of what stores what.
#=> Or more specifically, what is stored in what?
#=> So we would build up an object where
#=> - shiny gold bag points to bright white, and muted yellow.
#=> - white points to dark orange and light red (as does muted yellow)

#=> To get count, just follow dependency chain upwards counting uniques

test_input = ReadInput.string_list(Path.join("inputs", "7_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "7.txt"))

#=> Part 1 Testing
values = DaySeven.part_one(test_input)
IO.inspect values

values = DaySeven.part_one(real_input)
IO.inspect values

values = DaySeven.part_two(test_input)
IO.inspect values

values = DaySeven.part_two(real_input)
IO.inspect values
