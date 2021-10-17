defmodule Servy.Recurse do
  def sum([head | tail], total) do
    total = total + head
    sum(tail, total)
  end

  def sum([], total), do: total

  def triple([head | tail], tripled_list) do
    tripled_list = [head * 3 | tripled_list]
    triple(tail, tripled_list)
  end

  def triple([], tripled_list), do: tripled_list |> Enum.reverse()
end

IO.inspect(Servy.Recurse.sum([1, 2, 3, 4, 5], 0))
IO.inspect(Servy.Recurse.triple([1, 2, 3, 4, 5], []))
