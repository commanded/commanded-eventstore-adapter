defmodule Commanded.EventStore.Adapters.EventStore.DynamicEventStoreTest do
  use ExUnit.Case

  import Commanded.EventStore.EventStoreTestCase, only: [start_event_store: 1]

  alias Commanded.EventStore.Adapters
  alias Commanded.EventStore.Adapters.EventStore.Storage
  alias Commanded.EventStore.EventData

  defmodule BankAccountOpened do
    @derive Jason.Encoder
    defstruct [:account_number, :initial_balance]
  end

  setup_all do
    {:ok, conn1} = Storage.connect("schema1")
    {:ok, conn2} = Storage.connect("schema2")

    create_init_store!("schema1")
    create_init_store!("schema2")

    [conn1: conn1, conn2: conn2]
  end

  setup %{conn1: conn1, conn2: conn2} do
    {:ok, event_store_meta1} = start_event_store(name: :schema1, schema: "schema1")
    {:ok, event_store_meta2} = start_event_store(name: :schema2, schema: "schema2")

    on_exit(fn ->
      Storage.reset!(conn1)
      Storage.reset!(conn2)
    end)

    [event_store_meta1: event_store_meta1, event_store_meta2: event_store_meta2]
  end

  describe "dynamic event store" do
    test "should append events to named event store", %{
      event_store_meta1: event_store_meta1,
      event_store_meta2: event_store_meta2
    } do
      alias Adapters.EventStore

      assert :ok == EventStore.append_to_stream(event_store_meta1, "stream", 0, build_events(1))

      assert {:error, :stream_not_found} == EventStore.stream_forward(event_store_meta2, "stream")
    end
  end

  defp build_events(count, correlation_id \\ UUID.uuid4(), causation_id \\ UUID.uuid4())

  defp build_events(count, correlation_id, causation_id) do
    for account_number <- 1..count,
        do: build_event(account_number, correlation_id, causation_id)
  end

  defp build_event(account_number, correlation_id, causation_id) do
    %EventData{
      correlation_id: correlation_id,
      causation_id: causation_id,
      event_type: "#{__MODULE__}.BankAccountOpened",
      data: %BankAccountOpened{account_number: account_number, initial_balance: 1_000},
      metadata: %{"metadata" => "value"}
    }
  end

  defp create_init_store!(schema) do
    config = Storage.config(schema)

    EventStore.Tasks.Create.exec(config, quiet: true)
    EventStore.Tasks.Init.exec(TestEventStore, config, quiet: true)
  end
end
