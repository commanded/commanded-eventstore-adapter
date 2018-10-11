defmodule Commanded.EventStore.Adapters.EventStore.SnapshotTest do
  use Commanded.EventStore.SnapshotTestCase

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
