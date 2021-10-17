defmodule Servy.Conv do
  defstruct method: "", path: "", params: %{}, resp_body: "", status: nil

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      204 => "No Content",
      404 => "Not Found"
    }[code]
  end
end
