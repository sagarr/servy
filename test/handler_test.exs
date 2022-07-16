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

  test "GET /api/todos" do
    request = """
    GET /api/todos HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: application/json\r
    Content-Length: 83\r
    \r
    🤖 [{\"id\":1,\"note\":\"foo\",\"priority\":\"\"},{\"id\":2,\"note\":\"bar\",\"priority\":\"\"}] 🤖

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

  test "POST /api/todos" do
    request = """
    POST /api/todos HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/json\r
    Content-Length: 21\r
    \r
    {"id": "1", "priority": "High"}
    """

    response = handle(request)

    assert response == """
           HTTP/1.1 201 Created\r
           Content-Type: text/html\r
           Content-Length: 23\r
           \r
           Todo created with ID: 1
           """
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end