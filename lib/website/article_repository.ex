defmodule Website.ArticleRepository do
  @moduledoc "This module fetches all articles"

  use Website.ArticleLoader

  alias Website.Article

  @doc "Returns an unordered list of all articles even if their publish date is in the future"
  @spec list_all :: [%Article{}]
  def list_all, do: @articles

  @doc "Gives all published articles in chronological order"
  @spec published :: [%Article{}]
  def published do
    list_all()
    |> Enum.filter(&Article.published?/1)
    |> Enum.sort({:desc, Article})
  end
end
