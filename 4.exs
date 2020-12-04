defmodule DayFour do
  def part_one(string_list) do
    passports = separate_out_passports(string_list)
    valid_passports = Enum.filter(passports, &passport_has_keys?(&1))
    length valid_passports
  end

  def part_two(string_list) do
    passports = separate_out_passports(string_list)
    validators = [
      &birthy_valid?(&1),
      &issuancy_valid?(&1),
      &exp_valid?(&1),
      &height_valid?(&1),
      &hairc_valid?(&1),
      &eyec_valid?(&1),
      &pid_valid?(&1),
    ]
    valid_passports = Enum.filter(
      passports,
      fn passp ->
        passport_has_keys?(passp) and Enum.all?(
          validators,
          fn validator -> validator.(passp) end
        )
      end
    )
    IO.inspect(valid_passports)
    length valid_passports
  end

  def passport_has_keys?(passport) do
    fields = Map.keys(passport)
    Enum.all?(
      [ "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"],
      fn x -> Enum.member?(fields, x) end
    )
  end

  def birthy_valid?(passport) do
    year_str = Map.get(passport, "byr")
    { year, _ } = Integer.parse(year_str)
    String.length(year_str) === 4 and is_number(year) and year >= 1920 and year <= 2002
  end

  def issuancy_valid?(passport) do
    year_str = Map.get(passport, "iyr")
    { year, _ } = Integer.parse(year_str)
    String.length(year_str) === 4 and is_number(year) and year >= 2010 and year <= 2020
  end

  def exp_valid?(passport) do
    year_str = Map.get(passport, "eyr")
    { year, _ } = Integer.parse(year_str)
    String.length(year_str) === 4 and is_number(year) and year >= 2020 and year <= 2030
  end

  def height_valid?(passport) do
    year_str = Map.get(passport, "hgt")
    { height, unit } = Integer.parse(year_str)
    case unit do
      "cm" -> height >= 150 and height <= 193
      "in" -> height >= 59 and height <= 76
      _ -> false
    end
  end

  def hairc_valid?(passport) do
    hair_color = Map.get(passport, "hcl")
    String.match?(hair_color, ~r/^#[a-f | 0-9]{6}/)
  end

  def eyec_valid?(passport) do
    eye_c = Map.get(passport, "ecl")
    valid_colors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    Enum.member?(valid_colors, eye_c)
  end

  def pid_valid?(passport) do
    pid = Map.get(passport, "pid")
    String.match?(pid, ~r/^[0-9]{9}$/)
  end

  def separate_out_passports(lines) do
    passports = Enum.reduce(lines, [[]],
      fn line, [current_passport | prev_passports] ->
        case String.length(line) do
          x when x > 0 -> [[line | current_passport] | prev_passports]
          _ -> [[]] ++ [current_passport | prev_passports]
        end
      end
    )
    flattened = flatten_passports(passports)
    Enum.map(flattened, &convert_passport_to_map(&1))
  end

  def flatten_passports(passports) do
    Enum.map(passports,
      fn passport ->
        String.split(Enum.reduce(passport, "", fn passport_chunk, acc -> acc <> " " <> passport_chunk end))
      end
    )
  end

  def convert_passport_to_map(passport) do
    Enum.reduce(
      Enum.map(passport, &String.split(&1, ":")),
      %{},
      fn [field, value], acc -> Map.put(acc, field, value) end
    )
  end
end

#=> Part 1 Testing
# input = ReadInput.string_list(Path.join("inputs", "4_test.txt"))
# values = DayFour.part_one(input)
# IO.inspect values
#
# #=> Part 1
# input = ReadInput.string_list(Path.join("inputs", "4.txt"))
# values = DayFour.part_one(input)
# IO.inspect values

#=> Part 2 Testing
input = ReadInput.string_list(Path.join("inputs", "4_test.txt"))
values = DayFour.part_two(input)
IO.inspect values

#=> Part 2 Testing
input = ReadInput.string_list(Path.join("inputs", "4_test_2.txt"))
values = DayFour.part_two(input)
IO.inspect values

# #=> Part 1
input = ReadInput.string_list(Path.join("inputs", "4.txt"))
values = DayFour.part_two(input)
IO.inspect values

#
# #=> Part 1
# input = ReadInput.string_grid(Path.join("inputs", "3.txt"))
# values = DayFour.part_two(input)
# IO.inspect values
