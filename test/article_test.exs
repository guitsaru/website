defmodule Website.ArticleTest do
  use ExUnit.Case, async: true

  alias Website.Article

  describe "parse/1" do
    @filename to_string(:code.priv_dir(:website)) <> "/articles/the-pipeline.md"
    setup do: %{article: Article.parse(@filename)}

    test "has a slug", %{article: article} do
      assert article.slug == "the-pipeline"
    end

    test "has a title", %{article: article} do
      assert article.title == "Elixir Design Patterns - The Pipeline"
    end

    test "has a published at date", %{article: article} do
      assert article.published_at == ~D[2017-03-20]
    end

    test "has categories", %{article: article} do
      assert article.categories == ["elixir"]
    end

    test "has body", %{article: article} do
      {:safe, html} = article.body

      assert html =~ "<p>"
    end
  end
end
