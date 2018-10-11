defmodule Commanded.EventStore.Adapters.EventStore.AppendEventsTest do
  use Commanded.EventStore.AppendEventsTestCase

  alias Commanded.EventStore.Adapters.EventStore.Storage

  setup_all do
    {:ok, conn} = Storage.connect()

    [conn: conn]
  end

  setup %{conn: conn} do
    on_exit(fn ->
      Storage.reset!(conn)
    end)

    :ok
  end
end
