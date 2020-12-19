defmodule DayEighteen do
  def part_one(equations) do
    parsed = Enum.map(equations, &parse_equation(&1))
    results = Enum.map(parsed, &evaluate_equation_no_precedence(&1))
    Enum.sum(results)
  end

  def part_two(equations) do
    parsed = Enum.map(equations, &parse_equation(&1))
    results = Enum.map(parsed, &evaluate_equation_addition_precedence(&1))
    Enum.sum(results)
  end

  def evaluate_equation_no_precedence(equation_list) do
    #=> Flatten equation completely by evaluating each part recursively
    #=> Then we can just go left to right.
    [first_num | rest] = flatten_equation(equation_list, &evaluate_equation_no_precedence(&1))

    { total, _ } = Enum.reduce(rest, { first_num, nil }, fn next_part, { running_total, operator } ->
      case is_float(next_part) do
        true -> { perform_operation(running_total, next_part, operator), nil }
        false -> { running_total, next_part }
      end
    end)

    total
  end

  def evaluate_equation_addition_precedence(equation_list) do
    flat_equation = flatten_equation(equation_list, &evaluate_equation_addition_precedence(&1))
    chunked_by_addition = Enum.chunk_by(flat_equation, fn x -> x === "*" end)
    evaluate_equation_no_precedence(chunked_by_addition)
  end

  def flatten_equation(equation_list, eval_func) do
    Enum.map(equation_list, fn part ->
      case is_list(part) do
        true -> eval_func.(part)
        _ -> part
      end
    end)
  end

  def perform_operation(n1, n2, operator) when operator === "*", do: n1 * n2
  def perform_operation(n1, n2, operator) when operator === "+", do: n1 + n2

  def parse_equation(equation_str) do
    nested_by_parens = break_up_by_parantheses(String.graphemes(equation_str), [])
    consolidated = consolidate_numbers(nested_by_parens)
    convert_to_floats(consolidated)
  end

  #=> Turn 1 + (2 * 3) + (4 * (5 + 6))
  #=> Into { 1, +, { 2, *, 3 }, +, { 4, *, { 5, +, 6 }}}
  def break_up_by_parantheses([next_grapheme | rest], current_section) do
    #=> If this is a ), then we want to close out the current item list and return.
    #=> Need to also return what's left so higher level function can pick up where it left off
    #=> The recursion was kicked off to finish this particular chain of parantheses.
    case next_grapheme do
      ")" -> { rest, current_section }
      "(" ->
        { beyond_closing_paren, section } = break_up_by_parantheses(rest, [])
        break_up_by_parantheses(beyond_closing_paren, current_section ++ [section])
      x -> break_up_by_parantheses(rest, current_section ++ [x])
    end

    #=> Need to loop further
  end

  def break_up_by_parantheses([], current_section), do: current_section

  def consolidate_numbers(nested_by_parens) do
    chunked_by_space = Enum.chunk_by(nested_by_parens, fn x -> x === " " end)
    #=> Remove the groups that are whitespace
    chunked_by_space = Enum.filter(chunked_by_space, fn group ->
      not Enum.any?(group, fn x -> x === " " end)
    end)

    Enum.map(chunked_by_space, fn group ->
      case is_list(Enum.at(group, 0)) do
        true -> Enum.flat_map(group, &consolidate_numbers(&1))
        false -> Enum.join(group, "")
      end
    end)
  end

  def convert_to_floats([head|tail]) when is_list(head), do: [convert_to_floats(head)] ++ convert_to_floats(tail)
  def convert_to_floats([head|tail]) do
    case Float.parse(head) do
      { float, _ } -> [float] ++ convert_to_floats(tail)
      _ -> [head] ++ convert_to_floats(tail)
    end
  end
  def convert_to_floats([]), do: []

end

test_input = ReadInput.string_list(Path.join("inputs", "18_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "18.txt"))

#=> Part 1 Testing
values = DayEighteen.part_one(test_input)
IO.inspect values

values = DayEighteen.part_one(real_input)
IO.inspect values
#
values = DayEighteen.part_two(test_input)
IO.inspect values
#
values = DayEighteen.part_two(real_input)
IO.inspect values
