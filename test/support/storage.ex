defmodule Commanded.EventStore.Adapters.EventStore.Storage do
  alias EventStore.Config
  alias EventStore.Storage.Initializer

  def connect(schema \\ "public") do
    postgrex_config = schema |> config() |> Config.default_postgrex_opts()

    Postgrex.start_link(postgrex_config)
  end

  def config(schema \\ "public") do
    TestEventStore
    |> Config.parsed(:commanded_eventstore_adapter)
    |> Keyword.put(:schema, schema)
  end

  def reset!(conn), do: Initializer.reset!(conn)
end
