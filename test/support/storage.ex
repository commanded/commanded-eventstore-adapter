defmodule Commanded.EventStore.Adapters.EventStore.Storage do
  alias EventStore.Config
  alias EventStore.Storage.Initializer

  def connect do
    postgrex_config =
      Config.parsed(TestEventStore, :commanded_eventstore_adapter)
      |> Config.default_postgrex_opts()

    Postgrex.start_link(postgrex_config)
  end

  def reset!(conn), do: Initializer.reset!(conn)
end
