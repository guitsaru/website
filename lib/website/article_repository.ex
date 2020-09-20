defmodule Website.ArticleRepository do
  use Website.ArticleLoader

  alias Website.Article

  @spec list_all :: [%Article{}]
  def list_all, do: @articles

  @spec published :: [%Article{}]
  def published do
    list_all()
    |> Enum.filter(&Article.published?/1)
    |> Enum.sort({:desc, Article})
  end
end
