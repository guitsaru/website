defmodule WebsiteWeb.PageController do
  use WebsiteWeb, :controller

  alias Website.ArticleRepository

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    articles = ArticleRepository.published() |> Enum.take(9)

    render(conn, "index.html", articles: articles)
  end
end
