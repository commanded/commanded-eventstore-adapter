defmodule Commanded.EventStore.Adapters.EventStore.Storage do
  alias EventStore.Config
  alias EventStore.Storage.Initializer

  def connect do
    postgrex_config = Config.parsed() |> Config.default_postgrex_opts()

    Postgrex.start_link(postgrex_config)
  end

  def reset!(conn) do
    Application.stop(:eventstore)

    Initializer.reset!(conn)

    Application.ensure_all_started(:eventstore)
  end
end
