defmodule Servy.Todos do

  alias Servy.Todo

  def list_todos do
    [
      %Todo{id: 1, note: "foo"},
      %Todo{id: 2, note: "bar"}
    ]
  end

  def get_todo(id) when is_integer(id) do
    list_todos() |> Enum.find(fn (t) -> t.id == id end)
  end

  def get_todo(id) when is_binary(id) do
    id |> String.to_integer |> get_todo
  end
end
