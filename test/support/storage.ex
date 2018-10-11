defmodule Commanded.EventStore.Adapters.EventStore.Storage do
  def connect do
    postgrex_config = EventStore.Config.parsed() |> EventStore.Config.default_postgrex_opts()

    Postgrex.start_link(postgrex_config)
  end

  def reset!(conn) do
    Application.stop(:eventstore)

    EventStore.Storage.Initializer.reset!(conn)

    Application.ensure_all_started(:eventstore)
  end
end
