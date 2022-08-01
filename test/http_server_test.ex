defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "accept request and sends back response" do
    spawn(HttpServer, :start, [8000])


    1..5
    |> Enum.map(fn _ -> Task.async(fn -> HTTPoison.get("http://localhost:8000/todos/1") end) end)
    |> Enum.map(&Task.await/1)
    |> Enum.each(&assert_response/1)
  end

  defp assert_response({:ok, response}) do
    assert response.status_code == 200
  end
end