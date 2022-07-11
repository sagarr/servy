defmodule ParserTest do
  use ExUnit.Case

  alias Servy.Parser

  @moduletag :capture_log

  doctest Servy.Parser

  test "parses a list for header fields into a map" do
    header_lines = ["A: 1", "B: 2"]

    headers = Parser.parse_headers(header_lines, %{})

    assert headers == %{"A" => "1", "B" => "2"}
  end
end
