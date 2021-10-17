defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser
  import Servy.FileHandler

  @pages_path Path.expand("pages", File.cwd!())

  alias Servy.Conv

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

  def route(%Conv{method: "GET", path: "/todos"} = conv) do
    %{conv | resp_body: "grocery", status: 200}
  end

  def route(%Conv{method: "GET", path: "/todos/" <> id} = conv) do
    %{conv | resp_body: "todo #{id}", status: 200}
  end

  def route(%Conv{method: "POST", path: "/todos"} = conv) do
    %{
      conv
      | resp_body:
          "Todo created for #{conv.params["note"]} with priority #{conv.params["priority"]}",
        status: 201
    }
  end

  def route(%Conv{method: "GET", path: "/notes"} = conv) do
    %{conv | resp_body: "meeting", status: 200}
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "No #{path} here!", status: 404}
  end

  def emojify(%Conv{status: 200} = conv) do
    %{conv | resp_body: "👍🏼 #{conv.resp_body} 🤖"}
  end

  def emojify(%Conv{} = conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /todos HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /notes HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /foo HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /todos/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /todo HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
DELETE /todos/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /todos?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /pages/about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /pages/contact HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
GET /todos/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))

request = """
POST /todos HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Lenght: 21

note=grocery&priority=medium
"""

IO.puts(Servy.Handler.handle(request))
