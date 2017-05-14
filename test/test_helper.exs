ExUnit.start()

Mix.Task.run("event_store.create", ~w(--quiet))

# configure this event store adapter for Commanded
Application.put_env(:commanded, :event_store_adapter, Commanded.EventStore.Adapters.EventStore)

Application.put_env(:commanded, :reset_storage, fn ->
  Application.stop(:eventstore)

  storage_config = Application.get_env(:eventstore, EventStore.Storage)

  {:ok, conn} = Postgrex.start_link(storage_config)

  EventStore.Storage.Initializer.reset!(conn)

  Application.ensure_all_started(:eventstore)
end)
