defmodule WebsiteWeb.PageControllerTest do
  use WebsiteWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Hi, I'm Matt Pruitt"
  end
end
