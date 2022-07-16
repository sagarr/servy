defmodule Servy.Todo do
  @derive Jason.Encoder
  defstruct id: nil, note: "", priority: ""
end
