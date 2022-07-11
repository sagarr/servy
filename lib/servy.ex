defmodule Servy do
  @moduledoc """
  Documentation for `Servy`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Servy.hello("Sagar")
      "Hello, Sagar"

  """
  def hello(name) do
    "Hello, #{name}"
  end

end

IO.puts(Servy.hello("Sagar"))
