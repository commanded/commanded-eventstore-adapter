defmodule Commanded.EventStore.Adapters.EventStore.SubscriptionTest do
  use Commanded.EventStore.SubscriptionTestCase

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

  defp event_store_wait(_default \\ nil), do: 1_000
end
