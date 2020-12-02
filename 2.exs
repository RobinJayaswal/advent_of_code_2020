defmodule DayTwo do
  def part_one(password_policy_list) do
    validity_fn = &is_password_valid_part_one(&1, &2)
    count_valid_passwords(password_policy_list, validity_fn)
  end

  def part_two(password_policy_list) do
    validity_fn = &is_password_valid_part_two(&1, &2)
    count_valid_passwords(password_policy_list, validity_fn)
  end

  def count_valid_passwords(password_policy_list, validity_fn) do
    valid_passwords = get_valid_passwords(password_policy_list, validity_fn)
    length valid_passwords
  end

  def get_valid_passwords(password_policy_list, validity_fn) do
    Enum.filter(password_policy_list, fn password_policy_item ->
      case split_password_policy_item(password_policy_item) do
        [policy, password] -> validity_fn.(policy, password)
        _ -> false
      end
    end)
  end

  def is_password_valid_part_one(policy, password) do
    [range, required_letter] = String.split(policy, " ")
    [incl_min, incl_max] = Enum.map(String.split(range, "-"), &String.to_integer(&1))

    instances = (length String.split(password, required_letter)) - 1
    incl_min <= instances and instances <= incl_max
  end

  def is_password_valid_part_two(policy, password) do
    [range, required_letter] = String.split(policy, " ")
    [first_index, second_index] = Enum.map(String.split(range, "-"), &String.to_integer(&1))

    at_pos_one = String.at(password, first_index - 1) == required_letter
    at_pos_two =  String.at(password, second_index - 1) == required_letter
    (at_pos_one and not at_pos_two) or (not at_pos_one and at_pos_two)
  end

  defp split_password_policy_item(password_policy_item) do
    Enum.map(String.split(password_policy_item, ":"), &String.trim(&1))
  end

end


#=> Part 1 Testing
# test_case_1 = [
#   "1-3 a: abcde",
#   "1-3 b: cdefg",
#   "2-9 c: ccccccccc",
# ]
# IO.inspect(DayTwo.part_one(test_case_1))
#
# test_case_1 = [
#   "0-3 b: cdefg",
# ]
# IO.inspect(DayTwo.part_one(test_case_1))

#=> Part 1
input = ReadInput.string_list(Path.join("inputs", "2.txt"))
values = DayTwo.part_one(input)
IO.inspect values


#=> Part 2 Testing
# test_case_1 = [
#   "1-3 a: abcde",
#   "1-3 b: cdefg",
#   "2-9 c: ccccccccc",
# ]
# IO.inspect(DayTwo.part_two(test_case_1))

# #=> Part 2
input = ReadInput.string_list(Path.join("inputs", "2.txt"))
values = DayTwo.part_two(input)
IO.inspect values
