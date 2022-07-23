defmodule Servy.HttpClient do

  def send_request(req) do
    host = 'localhost'
    {:ok, socket} = :gen_tcp.connect(host, 8000, [:binary, packet: :raw, active: false])
    :ok = :gen_tcp.send(socket, req)
    {:ok, response} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    response
  end

end