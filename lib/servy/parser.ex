defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [path_and_headers, body] = request |> String.split("\n\n")

    [request_line | headers_line] = String.split(path_and_headers, "\n")

    headers = parse_headers(headers_line, %{})

    [method, path, _] = request_line |> String.split(" ")

    params = parse_params(headers["Content-Type"], body)

    %Conv{method: method, path: path, headers: headers, params: params}
  end

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-urlencoded", body) do
    body |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
