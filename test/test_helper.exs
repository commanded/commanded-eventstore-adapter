ExUnit.start()

Mix.Task.run("event_store.create", ~w(--quiet))

# configure this event store adapter for Commanded
Application.put_env(:commanded, :event_store_adapter, Commanded.EventStore.Adapters.EventStore)

Application.put_env(:commanded, :reset_storage, fn ->
  Application.stop(:eventstore)

  {:ok, conn} = EventStore.Config.parsed() |> Postgrex.start_link()

  EventStore.Storage.Initializer.reset!(conn)

  Application.ensure_all_started(:eventstore)
end)
