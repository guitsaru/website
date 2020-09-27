defmodule WebsiteWeb.RedirectTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Plug.Test

  describe "Redirect" do
    setup do
      opts = WebsiteWeb.Redirect.init(%{from: "/old", to: "/new"})

      {:ok, %{opts: opts}}
    end

    test "does nothing if from doesn't match", %{opts: opts} do
      conn = conn(:get, "/nomatch")
      conn = WebsiteWeb.Redirect.call(conn, opts)

      refute conn.state == :set
    end

    test "redirects if exact match", %{opts: opts} do
      conn = conn(:get, "/old")
      conn = WebsiteWeb.Redirect.call(conn, opts)

      assert conn.state == :set
      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/new/"]
    end

    test "redirects if partial match", %{opts: opts} do
      conn = conn(:get, "/old/slug")
      conn = WebsiteWeb.Redirect.call(conn, opts)

      assert conn.state == :set
      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/new/slug/"]
    end

    test "doesn't redirect if partial match in same segment", %{opts: opts} do
      conn = conn(:get, "/oldest")
      conn = WebsiteWeb.Redirect.call(conn, opts)

      assert conn.state == :unset
    end
  end
end
