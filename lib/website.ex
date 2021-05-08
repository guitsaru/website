defmodule Website do
  for app <- [:earmark, :makeup_elixir] do
    Application.ensure_all_started(app)
  end
end
