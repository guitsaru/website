defmodule WebsiteWeb.Redirect do
  import Plug.Conn

  @type options :: %{from: String.t(), to: String.t()}

  @spec init(options) :: options
  def init(options), do: options

  @spec call(Plug.Conn.t(), options) :: Plug.Conn.t()
  def call(%Plug.Conn{request_path: path} = conn, %{from: from, to: to}) do
    if String.starts_with?(path, from) do
      redirect_location = String.replace(path, from, to)

      conn
      |> put_resp_header("location", redirect_location)
      |> resp(301, "This resource has permanently moved")
      |> halt()
    else
      conn
    end
  end
end
