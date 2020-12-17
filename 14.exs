use Bitwise

defmodule DayFourteen do
  def part_one(program) do
    { memory, _ } = run_program(program, &update_memory_v1(&1, &2, &3))
    Enum.sum(Map.values(memory))
  end

  def part_two(program) do
    { memory, _ } = run_program(program, &update_memory_v2(&1, &2, &3))
    Enum.sum(Map.values(memory))
  end

  def run_program(program, update_memory_fn) do
    Enum.reduce(program, { %{}, nil }, fn program_line, { memory, bitmask } ->
      case is_mask(program_line) do
        true -> { memory, update_mask(program_line) }
        false -> { update_memory_fn.(memory, program_line, bitmask), bitmask }
      end
    end)
  end

  def is_mask(line) do
    { command, _ } = parse_command(line)
    command === :mask
  end

  def parse_command(line) do
    [lhs, rhs] = Enum.map(String.split(line, "="), &String.trim(&1))
    case lhs do
      "mask" -> { :mask, [rhs] }
      _ -> { :mem, [
            parse_memory_address(lhs),
            elem(Integer.parse(rhs), 0)
           ]}
    end
  end

  def parse_memory_address(mem_string) do
    [_, num] = Regex.run(~r/\[([0-9]+)]/, mem_string)
    elem(Integer.parse(num), 0)
  end

  def update_mask(line) do
    { _, [mask] } = parse_command(line)
    mask
  end

  def update_memory_v1(memory, line, bitmask) do
    {_, [address, value]} = parse_command(line)
    Map.put(memory, address, apply_bit_mask_v1(value, bitmask))
  end

  def update_memory_v2(memory, line, bitmask) do
    {_, [address, value]} = parse_command(line)
    addresses = memory_address_decoder(address, bitmask)

    Enum.reduce(addresses, memory, fn address_option, memory ->
      Map.put(memory, address_option, value)
    end)
  end

  def memory_address_decoder(memory_val, bitmask) do
    #=> Overwrite all the values that should be 1
    only_one_bit_mask = String.replace(bitmask, "0", "X")
    ones_applied = apply_bit_mask_v1(memory_val, only_one_bit_mask)

    generate_all_represented_memories(ones_applied, bitmask)
  end

  def apply_bit_mask_v1(value, bitmask) do
    bitmask_chars = Enum.with_index(Enum.reverse(String.graphemes(bitmask)))
    Enum.reduce(bitmask_chars, value, fn { char, index }, value_so_far ->
      case char do
        "X" -> value_so_far
        #=> Set index of the bitstring rep of value_so_far to zero, leaving rest unchanged.
        #=> By anding with a string of all 1s with a 0 in the index, we achieve this
        "0" -> value_so_far &&& round(create_0_mask_val(bitmask_chars, index))
        #=> Set index of the bitstring rep of value_so_far to one, leaving rest unchanged.
        #=> By oring with a string of all 0s with a 1 in the index, we achieve this
        "1" -> value_so_far ||| round(create_1_mask_val(bitmask_chars, index))
      end
    end)
  end

  def create_0_mask_val(bitmask_chars_w_ind, index) do
    mask = Enum.reduce(bitmask_chars_w_ind, 0, fn { _, char_index }, value ->
      case char_index do
        x when x === index -> value
        _ -> value + :math.pow(2, char_index)
      end
    end)
    mask
  end

  def create_1_mask_val(bitmask_chars_w_ind, index) do
    mask = Enum.reduce(bitmask_chars_w_ind, 0, fn { _, char_index }, value ->
      case char_index do
        x when x === index -> value + :math.pow(2, char_index)
        _ -> value
      end
    end)
    mask
  end

  def generate_all_represented_memories(memory_address, bitmask) do
    #=> Then wherever there is an X, generate both memory addresses. The ones
    #=> where we replace position with 0 and ones where we replace position with 1
    bitmask_chars = Enum.with_index(Enum.reverse(String.graphemes(bitmask)))
    Enum.reduce(bitmask_chars, [memory_address], fn { char, index }, addresses ->
      case char do
        "X" -> Enum.flat_map(addresses, fn address -> [
            address &&& round(create_0_mask_val(bitmask_chars, index)),
            address ||| round(create_1_mask_val(bitmask_chars, index))
          ] end)
        _ -> addresses
        # #=> Set index of the bitstring rep of value_so_far to zero, leaving rest unchanged.
        # #=> By anding with a string of all 1s with a 0 in the index, we achieve this
        # "0" -> value_so_far &&& round(create_0_mask_val(bitmask_chars, index))
        # #=> Set index of the bitstring rep of value_so_far to one, leaving rest unchanged.
        # #=> By oring with a string of all 0s with a 1 in the index, we achieve this
        # "1" -> value_so_far ||| round(create_1_mask_val(bitmask_chars, index))
      end
    end)
  end
end

test_input = ReadInput.string_list(Path.join("inputs", "14_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "14.txt"))

#=> Part 1 Testing
values = DayFourteen.part_one(test_input)
IO.inspect values
#
values = DayFourteen.part_one(real_input)
IO.inspect values
# # # #
values = DayFourteen.part_two(test_input)
IO.inspect values
# # # # #
values = DayFourteen.part_two(real_input)
IO.inspect values
