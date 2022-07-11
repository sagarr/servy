defmodule HandlerTest do
  use ExUnit.Case

  import Servy.Handler, only: [handle: 1]

  @moduletag :capture_log

  doctest Servy.Handler

  test "GET /todos" do
    request = """
    GET /todos HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 90\r
          \r
        🤖 Todos
           <ul>
              <li>1</li><li>foo</li>
              <li>2</li><li>bar</li>
           </ul>
        🤖
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  test "DELETE /todos/1" do
    request = """
    DELETE /todos/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)
                                                                                               
    expected_response = """
    HTTP/1.1 204 No Content\r
    Content-Type: text/html\r
    Content-Length: 0\r\r
    """
    assert  remove_whitespace(response) == remove_whitespace(expected_response)
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
