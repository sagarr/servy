defmodule Servy.Handler do
  @moduledoc false

  require Logger

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> emojify
    |> format_response
  end

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def rewrite_path(%{path: "/todo"} = conv) do
    %{conv | path: "/todos"}
  end

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv

  def log(conv) do
    Logger.info(conv)
    conv
  end

  def route(%{method: "GET", path: "/about"} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("about.html")
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

  def handle_file({:ok, content}, conv) do
    %{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found"}
  end

  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  def track(%{status: 404, path: path} = conv) do
    Logger.warn("warning: #{path} is on the loose!")
    conv
  end

  def track(conv), do: conv

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
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

IO.puts(Servy.Handler.handle(request))
