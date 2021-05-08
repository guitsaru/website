defmodule Website.Markdown do
  @moduledoc false

  def as_html!(markdown, options \\ []) do
    markdown
    |> Earmark.as_html!(options)
    |> Website.Highlighter.highlight()
  end
end
