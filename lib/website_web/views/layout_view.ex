defmodule WebsiteWeb.LayoutView do
  use WebsiteWeb, :view

  @spec title(Plug.Conn.t()) :: String.t()
  def title(conn) do
    conn.assigns |> Map.keys()

    if conn.assigns[:page_title] do
      conn.assigns[:page_title] <> " | Matt Pruitt"
    else
      "Matt Pruitt"
    end
  end
end
