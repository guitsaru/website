defmodule WebsiteWeb.ArticleControllerTest do
  @moduledoc false

  use WebsiteWeb.ConnCase

  test "GET /articles/", %{conn: conn} do
    conn = get(conn, "/articles")

    assert html = html_response(conn, 200)

    assert html =~ ~r[>\s*Articles\s*</h3>]
    assert html =~ "<title>Articles | Matt Pruitt</title>"
    assert html =~ ~r/href="\/articles\/[a-z-]+"/
  end

  test "GET /articles/tags/:tag", %{conn: conn} do
    conn = get(conn, "/articles/tags/elixir")

    assert html = html_response(conn, 200)

    assert html =~ ~r[>\s+Elixir Articles\s+</h3>]
    assert html =~ "<title>Elixir Articles | Matt Pruitt</title>"
    assert html =~ ~r/href="\/articles\/[a-z-]+"/
  end

  test "GET /articles/:slug", %{conn: conn} do
    conn = get(conn, "/articles/phoenix-forms-with-ecto-embedded-schema")

    assert html = html_response(conn, 200)

    assert html =~ "Use Ecto Embedded Schemas to Back Phoenix Forms</h1>"
    assert html =~ "<title>Use Ecto Embedded Schemas to Back Phoenix Forms | Matt Pruitt</title>"
  end
end
