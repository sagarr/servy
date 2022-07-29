defmodule UserApi do

  def query(id) do
    "https://jsonplaceholder.typicode.com/users/#{id}"
    |> HTTPoison.get
    |> handle_response
  end

  def handle_response({:ok,  %{status_code: 200, body: body}}) do
     city = case Jason.decode(body) do
        {:ok, body_map} -> body_map |> get_in(["address", "city"])
     end
     {:ok, city}
  end

  def handle_response({:ok, %{status_code: _status, body: body}}) do
    msg = case Jason.decode(body) do
      {:ok, body_map} -> body_map |> get_in(["message"])
    end
    {:error, msg}
  end

  def handle_response({:error, %{reason: reason}}) do
    {:error, "city not found: " + reason}
  end
end
