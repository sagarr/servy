defmodule Servy.TodoController do

  alias Servy.Todos

  @template_path Path.expand("template", File.cwd!())

  defp todo_item(t) do
    "<li>#{t.id}</li><li>#{t.note}</li>"
  end

  def index(conv) do
    todos = Todos.list_todos()

    content =
      @template_path
      |> Path.join("todos.eex")
      |> EEx.eval_file(todos: todos)

    %{conv | resp_body: content, status: 200}
  end

  def show(conv, %{"id" => id}) do
    todo = Todos.get_todo(id)
    %{conv | resp_body: "todo #{todo.note}", status: 200}
  end

  def create(conv, %{"note" => note, "priority" => prio}) do
    %{conv | resp_body: "Todo created for #{note} with priority #{prio}", status: 201}
  end
end
