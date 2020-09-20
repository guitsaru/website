defmodule WebsiteWeb.FeedController do
  use WebsiteWeb, :controller

  alias Atomex.{Entry, Feed}
  alias Website.ArticleRepository

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, _) do
    articles = ArticleRepository.published()
    feed = build_feed(articles)

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, feed)
  end

  defp build_feed(articles) do
    updated_at =
      articles
      |> List.first()
      |> Map.get(:published_at)
      |> to_datetime()

    "https://mattpruitt.com/"
    |> Feed.new(updated_at, "Matt Pruitt")
    |> Feed.author("Matt Pruitt", email: "matt@mattpruitt.com")
    |> Feed.link("https://mattpruitt.com/feed", rel: "self")
    |> Feed.entries(Enum.map(articles, &build_article_entry/1))
    |> Feed.build()
    |> Atomex.generate_document()
  end

  defp build_article_entry(article) do
    "https://mattpruitt.com/articles/#{article.slug}"
    |> Entry.new(to_datetime(article.published_at), article.title)
    |> Entry.content(to_html(article.body), type: "html")
    |> Entry.build()
  end

  defp to_html({:safe, html}), do: html

  defp to_datetime(date) do
    days = Date.diff(date, ~D[1970-01-01])

    DateTime.from_unix!(days * 24 * 60 * 60)
  end
end
