defmodule WebsiteWeb.Redirect do
  @moduledoc "Redirects old website paths to the new website paths for SEO purposes"

  import Plug.Conn

  @type options :: %{from: String.t(), to: String.t()}

  @spec init(options) :: options
  def init(options) do
    %{from: add_trailing_slash(options.from), to: add_trailing_slash(options.to)}
  end

  @spec call(Plug.Conn.t(), options) :: Plug.Conn.t()
  def call(%Plug.Conn{request_path: path} = conn, %{from: from, to: to}) do
    path = add_trailing_slash(path)

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

  defp add_trailing_slash(string) do
    if String.ends_with?(string, "/"), do: string, else: string <> "/"
  end
end
