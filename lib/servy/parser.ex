defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [path_and_headers, body] = request |> String.split("\n\n")

    [request_line | _] = String.split(path_and_headers, "\n")

    [method, path, _] = request_line |> String.split(" ")

    params = parse_params(body)

    %Conv{method: method, path: path, params: params}
  end

  def parse_params(body) do
    body |> String.trim() |> URI.decode_query()
  end
end
