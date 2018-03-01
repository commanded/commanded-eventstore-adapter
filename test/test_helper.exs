ExUnit.start()

Mix.Task.run("event_store.create", ~w(--quiet))

# Configure this event store adapter for Commanded
Application.put_env(:commanded, :event_store_adapter, Commanded.EventStore.Adapters.EventStore)

postgrex_config = EventStore.Config.parsed() |> EventStore.Config.default_postgrex_opts()

{:ok, conn} = Postgrex.start_link(postgrex_config)

Application.put_env(:commanded, :stop_storage, fn ->
  Application.stop(:eventstore)
end)

Application.put_env(:commanded, :reset_storage, fn ->
  EventStore.Storage.Initializer.reset!(conn)

  Application.ensure_all_started(:eventstore)

  :ok
end)
