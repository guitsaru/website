defmodule Website.ContentLoader do
  @moduledoc "Parses the given content into a collection."

  @priv_dir to_string(:code.priv_dir(:website))

  @doc """
  Sets the module's content path and loads all articles in at compile time. Takes
  the path of the article directory as it's argument.

  If your content is stored in `priv/articles` you should use `/articles`.

  ## Examples

      defmodule Website.ArticleRepository do
        use Website.ContentLoader, "/articles"
      end
  """
  @spec __using__(String.t()) :: any
  defmacro __using__(path) do
    article_dir = Path.join(@priv_dir, path)
    file_path = Path.join(article_dir, "/*.{livemd,md}")
    files = Path.wildcard(file_path)

    articles =
      files
      |> Enum.map(&Website.Article.parse/1)
      |> Macro.escape()

    quote location: :keep do
      for file <- unquote(files) do
        @external_resource file
      end

      def __mix_recompile__? do
        unquote(files)
        |> Enum.sort()
        |> :erlang.md5() != unquote(:erlang.md5(files))
      end

      def __phoenix_recompile__?, do: __mix_recompile__?()

      @articles unquote(articles)
    end
  end
end
