defmodule Website.Article do
  @moduledoc "This struct contains all the data for an article."

  defmodule ParseException, do: defexception([:message])

  defstruct slug: "",
            title: "",
            image: "",
            body: {:safe, ""},
            published_at: Date.utc_today(),
            categories: [],
            show_title: true

  @type safe_html :: {:safe, String.t()}

  @type t :: %__MODULE__{
          slug: String.t(),
          image: String.t(),
          title: String.t(),
          body: safe_html,
          published_at: Date.t(),
          categories: [String.t()],
          show_title: boolean()
        }

  @spec published?(%__MODULE__{}) :: boolean
  def published?(article) do
    case Date.compare(Date.utc_today(), article.published_at) do
      :lt -> false
      _ -> true
    end
  end

  @spec compare(%__MODULE__{}, %__MODULE__{}) :: :lt | :eq | :gt
  def compare(%__MODULE__{published_at: a}, %__MODULE__{published_at: b}), do: Date.compare(a, b)

  @type filename :: String.t()

  @spec parse(filename) :: %__MODULE__{}
  def parse(filename) do
    with {:ok, file} <- File.read(filename),
         [_, frontmatter, content] <- String.split(file, "---"),
         {:ok, attributes} <- parse_frontmatter(frontmatter),
         {:ok, parser} <- detect_parser(filename) do
      %__MODULE__{
        slug: Path.basename(filename, Path.extname(filename)),
        image: attributes.image,
        title: attributes.title,
        body: {:safe, parser.as_html!(content)},
        published_at: attributes.published_at,
        categories: Enum.map(attributes.categories, &String.downcase/1),
        show_title:
          Map.get(attributes, :show_title, !String.match?(Path.extname(filename), ~r/livemd/))
      }
    else
      _ -> raise __MODULE__.ParseException, "#{filename} could not be parsed"
    end
  end

  @spec parse_frontmatter(String.t()) :: {:ok, map} | {:error, String.t()}
  defp parse_frontmatter(raw) do
    {frontmatter, _} = Code.eval_string(raw, [])
    # This is a hack to get around a dialyzer type issue.
    frontmatter = Enum.into(frontmatter, %{})

    case frontmatter do
      %{} = frontmatter -> {:ok, frontmatter}
      _ -> {:error, "Can't parse the article's frontmatter"}
    end
  end

  @spec detect_parser(filename :: String.t()) :: {:ok, module()} | {:error, String.t()}
  defp detect_parser(filename) do
    case Path.extname(filename) do
      ".md" -> {:ok, Website.Markdown}
      ".livemd" -> {:ok, Website.Fakebook}
      ext -> {:error, "No parser for #{ext} files"}
    end
  end
end
