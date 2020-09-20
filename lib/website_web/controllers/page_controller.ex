defmodule WebsiteWeb.PageController do
  use WebsiteWeb, :controller

  alias Website.ArticleRepository

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    articles = ArticleRepository.published() |> Enum.take(3)

    render(conn, "index.html", articles: articles)
  end

  @spec contact(PLug.Conn.t(), map) :: Plug.Conn.t()
  def contact(conn, _) do
    render(conn, "contact.html")
  end
end
