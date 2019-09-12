defmodule EventStoreApplication do
  use Commanded.Application,
    otp_app: :commanded_eventstore_adapter,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: TestEventStore
    ]
end
