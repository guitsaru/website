defmodule WebsiteWeb.ArticleController do
  use WebsiteWeb, :controller

  alias Website.ArticleRepository

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _) do
    articles = ArticleRepository.published()

    render(conn, "index.html", articles: articles, page_title: "Articles")
  end

  @spec tag(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def tag(conn, %{"tag" => tag}) do
    page_title = String.capitalize(tag) <> " Articles"

    articles =
      ArticleRepository.published()
      |> Enum.filter(fn article -> String.downcase(tag) in article.categories end)

    render(conn, "index.html", articles: articles, page_title: page_title, tag: tag)
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"slug" => slug}) do
    article =
      Enum.find(ArticleRepository.published(), fn article ->
        String.downcase(article.slug) == String.downcase(slug)
      end)

    render(conn, "show.html", article: article, page_title: article.title)
  end
end
