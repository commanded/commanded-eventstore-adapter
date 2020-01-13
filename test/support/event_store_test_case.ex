defmodule Commanded.EventStore.EventStoreTestCase do
  use ExUnit.CaseTemplate

  alias Commanded.EventStore.Adapters.EventStore
  alias Commanded.EventStore.Adapters.EventStore.Storage

  setup_all do
    {:ok, conn} = Storage.connect()

    [conn: conn]
  end

  setup %{conn: conn} do
    {:ok, event_store_meta} = start_event_store()

    on_exit(fn ->
      Storage.reset!(conn)
    end)

    [event_store_meta: event_store_meta]
  end

  def start_event_store(config \\ []) do
    alias Commanded.EventStore.Adapters.EventStore

    config = Keyword.put_new(config, :event_store, TestEventStore)

    {:ok, child_spec, event_store_meta} = EventStore.child_spec(EventStoreApplication, config)

    for child <- child_spec do
      start_supervised!(child)
    end

    {:ok, event_store_meta}
  end
end
