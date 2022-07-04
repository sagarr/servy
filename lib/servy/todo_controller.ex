defmodule Servy.TodoController do

  alias Servy.Todos

  defp todo_item(t) do
    "<li>#{t.id}</li><li>#{t.note}</li>"
  end

  def index(conv) do
    todos =
      Todos.list_todos()
      |> Enum.map(&todo_item/1)
      |> Enum.join

    %{conv | resp_body: "<ul>#{todos}</ul>", status: 200}
  end

  def show(conv, %{"id" => id}) do
    todo = Todos.get_todo(id)
    %{conv | resp_body: "todo #{todo.note}", status: 200}
  end

  def create(conv, %{"note" => note, "priority" => prio}) do
    %{conv | resp_body: "Todo created for #{note} with priority #{prio}", status: 201}
  end
end
