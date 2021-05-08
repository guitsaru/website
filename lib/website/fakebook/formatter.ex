defmodule Website.Fakebook.Formatter do
  @moduledoc false

  def format({:ok, :"do not show this result in output"}) do
    # Functions in the `IEx.Helpers` module return this specific value
    # to indicate no result should be printed in the iex shell,
    # so we respect that as well.
    :ignored
  end

  def format({:ok, {:module, _, _, _} = value}) do
    inspected = inspect(value, inspect_opts(limit: 10))
    inspected
  end

  def format({:ok, value}) do
    inspected = inspect(value, inspect_opts())
    inspected
  end

  def format({:error, kind, error, stacktrace}) do
    formatted = Exception.format(kind, error, stacktrace)
    formatted
  end

  defp inspect_opts(opts \\ []) do
    default_opts = [pretty: true, width: 100]
    Keyword.merge(default_opts, opts)
  end
end
