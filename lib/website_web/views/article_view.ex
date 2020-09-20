defmodule WebsiteWeb.ArticleView do
  use WebsiteWeb, :view

  def category_color("elixir"), do: "indigo"
  def category_color("ruby"), do: "red"
  def category_color(_), do: "blue"
end
