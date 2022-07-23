defmodule Servy.Timer do

  def remind(about, time) do
    spawn(fn -> :timer.sleep(1000*time); IO.puts about end)
  end

end

Servy.Timer.remind("Stand up", 1)
Servy.Timer.remind("Fight, Fight, Fight", 5)

#:timer.sleep(:infinity)