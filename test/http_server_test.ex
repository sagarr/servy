defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer
  alias Servy.HttpClient

  test "accept request and sends back response" do
    spawn(HttpServer, :start, [8000])

    parent = self()

    for i <- 0..5 do
      spawn(fn ->
        {:ok, response} = HTTPoison.get("http://localhost:8000/todos/1")
        send(parent, response)
      end)
    end

    for _ <- 0..5 do
      receive do
        response ->
          assert 200 = response.status_code
      end
    end
  end
end