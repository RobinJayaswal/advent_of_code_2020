defmodule DayEight do
  def part_one(lines) do
    { accumulator, _i, _o, _v, _c } = execute_code(lines)
    accumulator
  end

  def part_two(lines) do
    candidate_lines = Enum.filter(
      Enum.with_index(lines),
      fn { line, _i } -> Enum.member?(["jmp", "nop"], Enum.at(String.split(line), 0)) end
    )
    Enum.reduce(
      candidate_lines,
      { false, 0 },
      fn { _l, index }, { completion_found, accumulator } ->
        case completion_found do
          true -> { completion_found, accumulator }
          false -> check_if_run_to_completion(
            flip_line(lines, index)
          )
        end
      end
    )
  end

  def flip_line(lines, index) do
    [op, arg] = String.split(Enum.at(lines, index))
    case op do
      "jmp" -> Enum.take(lines, index) ++ ["nop" <> " " <> arg] ++ Enum.take(lines, index + 1 - (length lines))
      "nop" -> Enum.take(lines, index) ++ ["jmp" <> " " <> arg] ++ Enum.take(lines, index + 1 - (length lines))
    end
  end

  def check_if_run_to_completion(lines) do
    { accumulator, _i, _o, _v, completed } = execute_code(lines)
    { completed, accumulator }
  end

  def execute_code(lines) do
    #=> map_reduce with an accumulator value
    #=> and a list of ops
    #=> and the current operation index
    #=> and an array of same length as ops that has booleans for whether op at index is visited
    ops_length = length lines
    Enum.reduce(
      lines,
      { 0, 0, lines, Enum.map(lines, fn _ -> false end), false },
      fn _, { accumulator, op_index, ops, visited_ops, completed } ->
        case op_index do
          x when x >= ops_length -> { accumulator, op_index, ops, visited_ops, true }
          _ -> Tuple.append(perform_op({ accumulator, op_index, ops, visited_ops }), completed)
        end
      end
    )
  end

  def perform_op({ accumulator, op_index, ops, visited_ops }) do
    case Enum.at(visited_ops, op_index) do
      true -> { accumulator, op_index, ops, visited_ops }
      false -> execute_line({ accumulator, op_index, ops, visited_ops })
    end
  end

  def execute_line({ accumulator, op_index, ops, visited_ops }) do
    [current_op, arg] = String.split(Enum.at(ops, op_index))
    { arg_int, _r } = Integer.parse(arg)
    new_visited_ops = Enum.take(visited_ops, op_index)
      ++ [true]
      ++ Enum.take(visited_ops, (op_index + 1) - (length visited_ops))

    case current_op do
      "nop" -> { accumulator, op_index + 1, ops, new_visited_ops }
      "acc" -> { accumulator + arg_int, op_index + 1, ops, new_visited_ops }
      "jmp" -> { accumulator, op_index + arg_int, ops, new_visited_ops }
    end
  end
end

test_input = ReadInput.string_list(Path.join("inputs", "8_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "8.txt"))

#=> Part 1 Testing
values = DayEight.part_one(test_input)
IO.inspect values

values = DayEight.part_one(real_input)
IO.inspect values

values = DayEight.part_two(test_input)
IO.inspect values

values = DayEight.part_two(real_input)
IO.inspect values
