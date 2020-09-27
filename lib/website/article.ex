defmodule Website.Article do
  @moduledoc "This struct contains all the data for an article."

  defmodule ParseException, do: defexception([:message])

  defstruct slug: "",
            title: "",
            image: "",
            body: {:safe, ""},
            published_at: Date.utc_today(),
            categories: []

  @type safe_html :: {:safe, String.t()}

  @type t :: %__MODULE__{
          slug: String.t(),
          image: String.t(),
          title: String.t(),
          body: safe_html,
          published_at: Date.t(),
          categories: [String.t()]
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
         {:ok, attributes} <- parse_frontmatter(frontmatter) do
      %__MODULE__{
        slug: Path.basename(filename, ".md"),
        image: attributes.image,
        title: attributes.title,
        body: {:safe, Earmark.as_html!(content)},
        published_at: attributes.published_at,
        categories: Enum.map(attributes.categories, &String.downcase/1)
      }
    else
      _ -> raise __MODULE__.ParseException, "#{filename} could not be parsed"
    end
  end

  defp parse_frontmatter(raw) do
    {frontmatter, _} = Code.eval_string(raw, [])
    # This is a hack to get around a dialyzer type issue.
    frontmatter = Enum.into(frontmatter, %{})

    case frontmatter do
      %{} = frontmatter -> {:ok, frontmatter}
      _ -> {:error, "Can't parse the article's frontmatter"}
    end
  end
end
