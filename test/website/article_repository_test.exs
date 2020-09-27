defmodule Website.ArticleRepositoryTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Website.ArticleRepository

  describe "list_all/0" do
    test "includes all articles" do
      article_path = Path.join(:code.priv_dir(:website), "articles/*.md")
      article_files = Path.wildcard(article_path)
      articles = ArticleRepository.list_all()

      assert is_list(articles)
      assert Enum.any?(articles)
      assert Enum.count(articles) == Enum.count(article_files)
    end
  end

  describe "published/0" do
    test "has articles" do
      published = ArticleRepository.published()

      assert Enum.any?(published)
    end

    test "has no draft articles" do
      published = ArticleRepository.published()

      refute Enum.any?(published, fn article ->
               Date.compare(Date.utc_today(), article.published_at) == :lt
             end)
    end

    test "is in published order" do
      articles = ArticleRepository.list_all()
      published = ArticleRepository.published()
      first = List.first(published)
      last = List.last(published)

      refute published == articles
      assert Date.compare(first.published_at, last.published_at) == :gt
    end
  end
end
