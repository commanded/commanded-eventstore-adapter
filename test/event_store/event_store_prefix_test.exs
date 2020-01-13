defmodule Commanded.EventStore.Adapters.EventStore.EventStorePrefixTest do
  use Commanded.EventStore.EventStorePrefixTestCase,
    event_store: Commanded.EventStore.Adapters.EventStore

  alias Commanded.EventStore.Adapters.EventStore.Storage
  alias Commanded.EventStore.EventStoreTestCase

  setup_all do
    {:ok, conn1} = Storage.connect("prefix1")
    {:ok, conn2} = Storage.connect("prefix2")

    create_init_store!("prefix1")
    create_init_store!("prefix2")

    [conn1: conn1, conn2: conn2]
  end

  setup %{conn1: conn1, conn2: conn2} do
    on_exit(fn ->
      Storage.reset!(conn1)
      Storage.reset!(conn2)
    end)
  end

  defdelegate start_event_store(config), to: EventStoreTestCase

  defp create_init_store!(schema) do
    config = Storage.config(schema)

    EventStore.Tasks.Create.exec(config, quiet: true)
    EventStore.Tasks.Init.exec(TestEventStore, config, quiet: true)
  end
end
