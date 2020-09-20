defmodule WebsiteWeb.ArticleController do
  use WebsiteWeb, :controller

  alias Website.ArticleRepository

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _) do
    articles = ArticleRepository.published()

    render(conn, "index.html", articles: articles)
  end

  @spec tag(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def tag(conn, %{"tag" => tag}) do
    articles =
      ArticleRepository.published()
      |> Enum.filter(fn article -> String.downcase(tag) in article.categories end)

    render(conn, "index.html", articles: articles)
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"slug" => slug}) do
    article =
      Enum.find(ArticleRepository.published(), fn article ->
        String.downcase(article.slug) == String.downcase(slug)
      end)

    render(conn, "show.html", article: article)
  end
end
