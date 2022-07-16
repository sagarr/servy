defmodule Servy.Api.TodoController do

  def index(conv) do
    json = Servy.Todos.list_todos()
           |> Jason.encode!

    headers = Map.put(conv.resp_headers, "Content-Type", "application/json")
    %{conv | status: 200, resp_body: json, resp_headers: headers}
  end

  def create(conv, %{"id" => id}) do
    %{conv | status: 201, resp_body: "Todo created with ID: #{id}"}
  end

end