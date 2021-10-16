defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser
  import Servy.FileHandler

  @pages_path Path.expand("pages", File.cwd!())

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

  def route(%{method: "GET", path: "/pages/" <> page} = conv) do
    @pages_path
    |> Path.join("#{page}.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: "GET", path: "/todos/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%{method: "DELETE"} = conv) do
    %{conv | status: 204}
  end

  def route(%{method: "GET", path: "/todos"} = conv) do
    %{conv | resp_body: "grocery", status: 200}
  end

  def route(%{method: "GET", path: "/todos/" <> id} = conv) do
    %{conv | resp_body: "todo #{id}", status: 200}
  end

  def route(%{method: "GET", path: "/notes"} = conv) do
    %{conv | resp_body: "meeting", status: 200}
  end

  def route(%{path: path} = conv) do
    %{conv | resp_body: "No #{path} here!", status: 404}
  end

  def emojify(%{status: 200} = conv) do
    %{conv | resp_body: "👍🏼 #{conv.resp_body} 🤖"}
  end

  def emojify(conv), do: conv

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      204 => "No Content",
      404 => "Not Found"
    }[code]
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
