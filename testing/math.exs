defmodule Math2 do
  def sum(a, b) do
    do_sum(a, b)
  end

  defp do_sum(a, b) do
    a + b
  end

  def zero?(0) do
    true
  end

  def zero?(x) when is_integer(x) do
    false
  end
end

IO.puts Math2.sum(1,2)
# IO.puts Math2.do_sum(1,2) => Errors on private function
IO.puts Math2.zero?(0)
IO.puts Math2.zero?(1)
# IO.puts Math2.zero?(0.0) => Errors on no matching clause

fun = &Math2.zero?/1
IO.puts is_function(fun)
IO.puts fun.(0)
