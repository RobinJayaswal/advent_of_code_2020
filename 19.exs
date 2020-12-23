defmodule DayNineteen do
  def part_one_and_two(input) do
    messages = parse_messages(input)
    rules = parse_rules(input)
    is_matching_list = Enum.map(messages, &message_matches_rule_completely?(rules[0], rules, &1))
    length Enum.filter(is_matching_list, fn x -> x end)
  end

  def message_matches_rule_completely?(rule, rules, message) do
    { match?, remaining_opts } = message_matches_rule?(rule, rules, message)
    match? and Enum.any?(remaining_opts, fn remaining_str -> String.length(remaining_str) === 0 end)
  end


  def message_matches_rule?([first_clause | rest_clauses], all_rules, message) when is_list(first_clause) do

    #=> Need to test all possible clauses and return the different options for 'rest'
    results_from_all_clauses = Enum.map(
      [first_clause | rest_clauses],
      &message_matches_rule?(&1, all_rules, message)
    )

    clauses_matched = Enum.filter(results_from_all_clauses, fn { match, _ } -> match end)

    #=> Should default to false if rest_clauses is empty
    case length clauses_matched do
      x when x > 0 -> { true, Enum.flat_map(clauses_matched, fn { _, rest } -> rest end) }
      _ -> { false, [message] }
    end
  end

  #=> Seems like it stops too early. Why?

  def message_matches_rule?([first_clause | rest_clauses], all_rules, message) when is_integer(first_clause) do
    { first_rule_match, remaining_str_options } = message_matches_rule?(
      all_rules[first_clause],
      all_rules,
      message
    )

    case first_rule_match do
      true -> try_all_remaining_strings(rest_clauses, all_rules, remaining_str_options, message)
      false -> { false, [message]}
    end

  end

  def message_matches_rule?([first_clause], _, message) when is_binary(first_clause) do
    {first_char, rest} = String.split_at(message, 1)
    {
      first_char === first_clause,
      [rest]
    }
  end

  def message_matches_rule?([], _, message) do
    { true, [message] }
  end

  def try_all_remaining_strings(rest_clauses, all_rules, remaining_str_options, message) do
    results_from_remaining_strings = Enum.map(remaining_str_options, fn remaining ->
      message_matches_rule?(rest_clauses, all_rules, remaining)
    end)

    clauses_matched = Enum.filter(results_from_remaining_strings, fn { match, _ } -> match end)

    #=> Should default to true if rest_clauses is empty
    case length clauses_matched do
      x when x > 0 -> { true, Enum.flat_map(clauses_matched, fn { _, rest } -> rest end)}
      _ -> { false, [message] }
    end
  end


  def parse_messages(input) do
    {_, messages} = Enum.split_while(input, fn x -> x !== "" end)
    Enum.slice(messages, 1..-1)
  end

  #=> An integer means a rule, a string means a character match
  def parse_rules(input) do
    {rules, _i} = Enum.split_while(input, fn x -> x !== "" end)

    Enum.reduce(rules, %{}, fn rule_str, parsed_rules ->
      [ind, rhs] = String.split(rule_str, ": ")

      { int_index, _ } = Integer.parse(ind)



      case Regex.run(~r/"([A-z])"/, rhs) do
        nil -> parse_clauses(parsed_rules, int_index, rhs)
        [_, char] -> Map.put(parsed_rules, int_index, [char])
      end
    end)
  end

  def parse_clauses(parsed_rules, int_index, rhs) do
    clauses = Enum.map(
      String.split(rhs, "|"),
      &parse_subrules_clause(&1)
    )

    #=> Expand any that have loops, as long as needed
    expanded = expand_loop_clauses(clauses, int_index, 0)

    Map.put(parsed_rules, int_index, expanded)
  end

  def expand_loop_clauses(clauses, int_index, depth) when depth < 3 do
    expanded_clauses = Enum.flat_map(clauses, fn clause ->
      matching_index = Enum.find_index(clause, fn x -> x === int_index end)
      case matching_index do
        nil -> [clause]
        _ -> Enum.map(clauses, fn recursive_clause ->
              Enum.slice(clause, 0..(matching_index - 1))
              ++ recursive_clause
              ++ Enum.slice(clause, (matching_index + 1)..-1)
             end)
      end
    end)

    expand_loop_clauses(expanded_clauses, int_index, depth + 1)
  end

  def expand_loop_clauses(clauses, int_index, _d) do
    Enum.filter(
      clauses,
      fn clause ->
        not Enum.any?(
          clause, fn x -> x === int_index end
        )
      end
    )
  end

  def parse_subrules_clause(clause) do
    subrules = String.split(String.trim(clause))
    Enum.map(subrules, fn subrule ->
      { int_rule, _ } = Integer.parse(subrule)
      int_rule
    end)
  end
end

test_input = ReadInput.string_list(Path.join("inputs", "19_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "19.txt"))

#=> Part 1 Testing
values = DayNineteen.part_one_and_two(test_input)
IO.inspect values

values = DayNineteen.part_one_and_two(real_input)
IO.inspect values
