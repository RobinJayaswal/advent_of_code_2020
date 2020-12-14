defmodule DayThirteen do
  def part_one(input) do
    { earliest_ts, bus_depart_intervals } = parse_input(input)
    { bus_id, departure_ts } = find_earliest_bus(earliest_ts, bus_depart_intervals)
    wait_time = departure_ts - earliest_ts
    wait_time * bus_id
  end
  def part_two(input) do
    #=> We go bus by bus finding minimum timestamp that satisfies that bus along with
    #=> all previous buses. Finding min ts for buses x, y, z will also serve as a min for x, y, z, w
    #=> We start with the first bus, and try to find a timestamp that satisfies it.
    #=>   We find 17 obviously after incrementing by 1 17 times.
    #=>   Now, we know that the minimum timestamp is 17
    #=>   Furthermore, we know that from here we should increment by 17, since we know that this bus
    #=>   runs on that schedule so no reason to check from here in increments less than 17
    #=> We move onto the second bus, and try to find a timestamp where the condition that
    #=> t + 2 (one x in between) is divisible by 13 holds
    #=>   We are incrementing by 17. We find 102 as a timestamp where (t + 2) / 13 is an integer.
    #=>   Now, we know that the minimum timestamp is 102. Since that is minimum that
    #=>   satisfies both 17 bus and 13 bus.
    #=>   Furthermore, since 17 and 13 share no common denominators, we know that
    #=>   we can now increment by 17 * 13 from here.
    #=>   To see why, assume we have 17 * x + 102 where x not divisible by 13,
    #=>   and 17x + 102 + 2 is divisible by 13
    #=>   (17x + 104) mod 13 = 0
    #=>     104 mod 13 = 0 hence we get
    #=>     17x mod 13 = 0
    #=>     4x mod 13 = 0
    #=>     x mod 13 != 0
    #=>     But this is not possible. 4x being divisible by 13 means that the unique prime
    #=>     factorization of 4x has thirteen in it. Since 4 clearly wont produce it,
    #=>     x must have 13 in its prime factorization.
    #=>     Hence we can safely step in increments of 17 * 13 without missing a valid
    #=>     timestamp that satisfies both bus 17 and 13.
    #=> Since every number is a prime we can do this at every step to make our increment larger
    #=> and larger

    { _, bus_depart_intervals } = parse_input(input)

    initial_increment = 1
    initial_timestamp = 1

    Enum.reduce(
      Enum.with_index(bus_depart_intervals),
      { initial_timestamp, initial_increment },
      fn { bus_id, offset }, { ts, increment } ->
        case bus_id do
          "x" -> { ts, increment }
          _ -> find_lowest_ts_satisfying_bus_id(ts, increment, bus_id, offset)
        end
      end)
  end

  def find_lowest_ts_satisfying_bus_id(ts, increment, bus_id, offset) do
    case rem(ts + offset, bus_id) do
      0 -> { ts, increment * bus_id }
      _ -> find_lowest_ts_satisfying_bus_id(ts + increment, increment, bus_id, offset)
    end
  end

  def find_earliest_bus(earliest_ts, bus_depart_intervals) do
    earliest_bus_timestamps = Enum.map(
      bus_intervals_without_x(bus_depart_intervals),
      fn interval ->
        { interval, ceil(earliest_ts / interval) * interval }
      end
    )
    Enum.min_by(earliest_bus_timestamps, fn { _, ts } -> ts end)
  end

  def bus_intervals_without_x(bus_depart_intervals) do
    Enum.filter(bus_depart_intervals, fn x -> x !== "x" end)
  end

  def parse_input(input) do
    [earliest_ts, bus_depart_intervals] = input
    { earliest_ts, _ } = Integer.parse(earliest_ts)
    bus_depart_intervals = Enum.map(
      String.split(bus_depart_intervals, ","),
      fn bus -> case bus do
        "x" -> bus
        _ -> elem(Integer.parse(bus), 0)
      end end
    )
    {
      earliest_ts,
      bus_depart_intervals
    }
  end
end

test_input = ReadInput.string_list(Path.join("inputs", "13_test.txt"))
real_input = ReadInput.string_list(Path.join("inputs", "13.txt"))

#=> Part 1 Testing
# values = DayThirteen.part_one(test_input)
# IO.inspect values
#
# values = DayThirteen.part_one(real_input)
# IO.inspect values
# # # #
values = DayThirteen.part_two(test_input)
IO.inspect values
# # # # #
values = DayThirteen.part_two(real_input)
IO.inspect values
