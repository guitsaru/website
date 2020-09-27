defmodule WebsiteWeb.FeedControllerTest do
  @moduledoc false

  use WebsiteWeb.ConnCase

  test "GET /feed", %{conn: conn} do
    conn = get(conn, "/feed")

    assert get_resp_header(conn, "content-type") == ["text/xml; charset=utf-8"]
    assert response = response(conn, 200)

    assert response =~ "<feed"
    assert response =~ "<entry"
    assert response =~ "https://mattpruitt.com"
  end
end
