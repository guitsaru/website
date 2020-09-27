defmodule Website.ArticleLoader do
  @moduledoc "Finds all article markdown files and parses them into a list of article structs."

  @article_dir to_string(:code.priv_dir(:website)) <> "/articles"

  @spec __using__(any) :: any
  defmacro __using__(_) do
    files = Path.wildcard(@article_dir <> "/*.md")

    articles =
      unquote(@article_dir)
      |> Path.join("/*.md")
      |> Path.wildcard()
      |> Enum.map(&Website.Article.parse/1)
      |> Macro.escape()

    quote do
      for file <- unquote(files) do
        @external_resource file
      end

      def __mix_recompile__? do
        unquote(@article_dir)
        |> Path.join("/*.md")
        |> Path.wildcard()
        |> Enum.sort()
        |> :erlang.md5() != unquote(:erlang.md5(files))
      end

      def __phoenix_recompile__?, do: __mix_recompile__?()

      @articles unquote(articles)
    end
  end
end
