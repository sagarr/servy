defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [path_and_headers, body] = request |> String.split("\r\n\r\n")

    [request_line | headers_line] = String.split(path_and_headers, "\r\n")

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

  @doc """
  Parses the given param string of the form `key1=value&key2=value2` into
  a map with corresponding keys and values.

  ## Examples
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", "name=Baloo&color=Brown")
    %{"name" => "Baloo", "color" => "Brown"}
    iex> Servy.Parser.parse_params("multipart/form-data", "name=Baloo&color=Brown")
    %{}
  """
  def parse_params("application/x-www-form-urlencoded", body) do
    body |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}
end
