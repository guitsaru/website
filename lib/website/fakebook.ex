defmodule Website.Fakebook do
  def as_html!(markdown, options \\ []) do
    {:ok, ast, []} = EarmarkParser.as_ast(markdown, options)

    ast
    |> Enum.reduce({[], []}, fn node, {a, binding} ->
      {transformed, binding} = transform(node, binding)
      {Enum.concat(a, [transformed]), binding}
    end)
    |> elem(0)
    |> Earmark.Transform.transform(options)
    |> Website.Highlighter.highlight()
  end

  defp transform({"pre", _, children, options} = pre, binding) do
    button = {
      "a",
      [
        {"href", "#"},
        {"@click.prevent", "evaluated = true"},
        {"class", "flex items-center -mb-8 text-sm text-red-500"}
      ],
      [
        icon(),
        "Run"
      ],
      []
    }

    {result_div, binding} = result_div(List.first(children), pre, binding)

    if result_div do
      {
        {
          "div",
          [
            {"x-data", "{evaluated: false}"}
          ],
          [
            button,
            pre,
            result_div
          ],
          options
        },
        binding
      }
    else
      {pre, binding}
    end
  end

  defp transform(other, binding), do: {other, binding}

  defp result_div(
         {"code", attributes, contents, options},
         {"pre", pre_attributes, _, pre_options},
         binding
       ) do
    is_elixir = is_elixir?(attributes)

    if is_elixir do
      {result, binding} = eval(contents, binding)

      {
        {
          "pre",
          pre_attributes ++ [{"x-show", "evaluated"}],
          {"code", attributes, [result], options},
          pre_options
        },
        binding
      }
    else
      {nil, binding}
    end
  end

  defp is_elixir?(attributes) do
    Enum.any?(attributes, fn
      {"class", "elixir"} -> true
      _ -> false
    end)
  end

  defp eval(code, binding) do
    {result, binding} = Code.eval_string(Enum.join(code, "\n"), binding)

    {Website.Fakebook.Formatter.format({:ok, result}), binding}
  end

  defp icon do
    """
    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
    </svg>
    """
    |> EarmarkParser.as_ast()
    |> elem(1)
  end
end
