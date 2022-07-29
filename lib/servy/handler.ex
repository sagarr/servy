defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser
  import Servy.FileHandler

  @pages_path Path.expand("pages", File.cwd!())

  alias Servy.Conv
  alias Servy.TodoController
  alias Servy.VideoCam

  @doc "Handle incoming http request and generates response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path()
    |> log()
    |> route
    |> track
    |> emojify
    |> format_response
  end

  def route(%Conv{ method: "GET", path: "/snapshots" } = conv) do
    parent = self()
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-1")}) end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-2")}) end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-3")}) end)

    snapshot1 = receive do
      {:result, filename} -> filename
    end
    snapshot2 = receive do
      {:result, filename} -> filename
    end
    snapshot3 = receive do
      {:result, filename} -> filename
    end

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{ conv | status: 200, resp_body: inspect snapshots}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = conv) do
    raise "kaboom!"
  end

  def route(%Conv{method: "GET", path: "/sleep/" <> time} = conv) do
   time |> String.to_integer |> :timer.sleep

   %{conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/pages/" <> page} = conv) do
    @pages_path
    |> Path.join("#{page}.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/todos/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "DELETE"} = conv) do
    %{conv | status: 204}
  end

  def route(%Conv{method: "GET", path: "/api/todos"} = conv) do
    Servy.Api.TodoController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/todos"} = conv) do
    TodoController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/todos/" <> id} = conv) do
    TodoController.show(conv,  Map.put(conv.params, "id", id))
  end

  def route(%Conv{method: "POST", path: "/todos"} = conv) do
    TodoController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/todos"} = conv) do
    Servy.Api.TodoController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/notes"} = conv) do
    %{conv | resp_body: "meeting", status: 200}
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "No #{path} here!", status: 404}
  end

  def emojify(%Conv{status: 200} = conv) do
    %{conv | resp_body: "🤖 #{conv.resp_body} 🤖"}
  end

  def emojify(%Conv{} = conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_headers["Content-Type"]}\r
    Content-Length: #{byte_size(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end


#request = """
#GET /notes HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#GET /foo HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#GET /todos/1 HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#GET /todo HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#DELETE /todos/1 HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#GET /todos?id=1 HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#GET /pages/about HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#GET /pages/contact HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#GET /todos/new HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#
#"""
#
#IO.puts(Servy.Handler.handle(request))
#
#request = """
#POST /todos HTTP/1.1
#Host: example.com
#User-Agent: ExampleBrowser/1.0
#Accept: */*
#Content-Type: application/x-www-form-urlencoded
#Content-Lenght: 21
#
#note=grocery&priority=medium
#"""
#
#IO.puts(Servy.Handler.handle(request))