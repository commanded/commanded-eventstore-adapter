defmodule Commanded.EventStore.EventStoreTestCase do
  use ExUnit.CaseTemplate

  alias Commanded.EventStore.Adapters.EventStore
  alias Commanded.EventStore.Adapters.EventStore.Storage

  setup_all do
    {:ok, conn} = Storage.connect()

    [conn: conn]
  end

  setup %{conn: conn} do
    config = [event_store: TestEventStore]

    {:ok, child_spec, event_store_meta} = EventStore.child_spec(EventStoreApplication, config)

    for child <- child_spec do
      start_supervised!(child)
    end

    on_exit(fn ->
      Storage.reset!(conn)
    end)

    [event_store_meta: event_store_meta]
  end
end
