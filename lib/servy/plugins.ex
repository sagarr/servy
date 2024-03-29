defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  def rewrite_path(%Conv{path: "/todo"} = conv) do
    %{conv | path: "/todos"}
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(conv, nil), do: conv

  def log(%Conv{} = conv) do
    Logger.info(conv)
    conv
  end

  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn("warning: #{path} is on the loose!")
    conv
  end

  def track(%Conv{} = conv), do: conv
end
