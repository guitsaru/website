defmodule WebsiteWeb.LayoutViewTest do
  use WebsiteWeb.ConnCase, async: true

  alias WebsiteWeb.LayoutView

  describe "page_title/1" do
    test "has a default title", %{conn: conn} do
      assert LayoutView.title(conn) == "Matt Pruitt"
    end

    test "includes the assigned page title", %{conn: conn} do
      title =
        conn
        |> Plug.Conn.assign(:page_title, "Test")
        |> LayoutView.title()

      assert title == "Test | Matt Pruitt"
    end
  end
end
