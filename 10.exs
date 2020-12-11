defmodule DayTen do
  def part_one(adapters) do
    chain = build_chain(adapters)
    { one_jumps, _t, three_jumps } = count_jolt_jumps_in_chain(chain)
    one_jumps * three_jumps
  end

  def part_two(adapters) do
    chain = build_chain(adapters)
    device_voltage = Enum.max(chain) + 3
    compute_ways_to_get_to_jolt([0] ++ chain ++ [device_voltage], device_voltage, %{})
  end

  def compute_ways_to_get_to_jolt(chain, jolt, memo) do
    index = Enum.find_index(chain, fn x -> round(x) === round(jolt) end)
    cond do
      memo[jolt] !== nil -> memo[jolt]
      index === nil -> 0
      round(jolt) < 0 -> 0
      round(jolt) === 0 -> 1
      round(jolt) === 1 -> 1
      true -> update_memo_and_return_sum(chain, jolt, memo)
    end
  end

  def update_memo_and_return_sum(chain, jolt, memo) do
    jolt_m3 = compute_ways_to_get_to_jolt(chain, jolt - 3, memo)
    memo = Map.put(memo, jolt - 3, jolt_m3)

    jolt_m2 = compute_ways_to_get_to_jolt(chain, jolt - 2, memo)
    memo = Map.put(memo, jolt - 2, jolt_m2)

    jolt_m1 = compute_ways_to_get_to_jolt(chain, jolt - 1, memo)

    jolt_m3 + jolt_m2 + jolt_m1
  end

  def build_chain(adapters) do
    Enum.sort(adapters)
  end

  def count_jolt_jumps_in_chain(chain) do
    { _, one_js, two_js, three_js } = Enum.reduce(
      chain,
      { 0, 0, 0, 0 },
      fn voltage, { previous_voltage, one_js, two_js, three_js } ->
        jump = voltage - previous_voltage
        case round(jump) do
          1 -> { voltage, one_js + 1, two_js, three_js }
          2 -> { voltage, one_js, two_js + 1, three_js }
          3 -> { voltage, one_js, two_js, three_js + 1 }
        end
      end
    )
    #=> Add one to the three jumps since the device always jumps by 3
    { one_js, two_js, three_js + 1 }
  end

end

test_input = ReadInput.float_list(Path.join("inputs", "10_test.txt"))
real_input = ReadInput.float_list(Path.join("inputs", "10.txt"))

#=> Part 1 Testing
values = DayTen.part_one(test_input)
IO.inspect values

values = DayTen.part_one(real_input)
IO.inspect values
#
values = DayTen.part_two(test_input)
IO.inspect values
#
values = DayTen.part_two(real_input)
IO.inspect values
