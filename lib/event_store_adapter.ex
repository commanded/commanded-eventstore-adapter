defmodule Commanded.EventStore.Adapters.EventStore do
  @moduledoc false

  alias Commanded.EventStore.Adapters.EventStore.Mapper

  @behaviour Commanded.EventStore

  @all_stream "$all"

  @impl Commanded.EventStore
  def child_spec(event_store, config) do
    event_store = get_event_store({event_store, config})

    verify_event_store!(event_store)

    [event_store]
  end

  @impl Commanded.EventStore
  def append_to_stream(event_store, stream_uuid, expected_version, events) do
    event_store = get_event_store(event_store)

    event_store.append_to_stream(
      stream_uuid,
      expected_version,
      Enum.map(events, &Mapper.to_event_data/1)
    )
  end

  @impl Commanded.EventStore
  def stream_forward(event_store, stream_uuid, start_version \\ 0, read_batch_size \\ 1_000) do
    event_store = get_event_store(event_store)

    case event_store.stream_forward(stream_uuid, start_version, read_batch_size) do
      {:error, error} -> {:error, error}
      stream -> Stream.map(stream, &Mapper.from_recorded_event/1)
    end
  end

  @impl Commanded.EventStore
  def subscribe(event_store, :all), do: subscribe(event_store, @all_stream)

  @impl Commanded.EventStore
  def subscribe(event_store, stream_uuid) do
    event_store = get_event_store(event_store)
    event_store.subscribe(stream_uuid, mapper: &Mapper.from_recorded_event/1)
  end

  @impl Commanded.EventStore
  def subscribe_to(event_store, :all, subscription_name, subscriber, start_from) do
    event_store = get_event_store(event_store)

    event_store.subscribe_to_all_streams(
      subscription_name,
      subscriber,
      subscription_options(start_from)
    )
  end

  @impl Commanded.EventStore
  def subscribe_to(event_store, stream_uuid, subscription_name, subscriber, start_from) do
    event_store = get_event_store(event_store)

    event_store.subscribe_to_stream(
      stream_uuid,
      subscription_name,
      subscriber,
      subscription_options(start_from)
    )
  end

  @impl Commanded.EventStore
  def ack_event(event_store, subscription, %Commanded.EventStore.RecordedEvent{} = event) do
    %Commanded.EventStore.RecordedEvent{event_number: event_number} = event

    event_store = get_event_store(event_store)
    event_store.ack(subscription, event_number)
  end

  @impl Commanded.EventStore
  def unsubscribe(_event_store, subscription) do
    EventStore.Subscriptions.Subscription.unsubscribe(subscription)
  end

  @impl Commanded.EventStore
  def delete_subscription(event_store, :all, subscription_name) do
    event_store = get_event_store(event_store)
    event_store.delete_subscription(@all_stream, subscription_name)
  end

  @impl Commanded.EventStore
  def delete_subscription(event_store, stream_uuid, subscription_name) do
    event_store.delete_subscription(stream_uuid, subscription_name)
  end

  @impl Commanded.EventStore
  def read_snapshot(event_store, source_uuid) do
    event_store = get_event_store(event_store)

    with {:ok, snapshot_data} <- event_store.read_snapshot(source_uuid) do
      {:ok, Mapper.from_snapshot_data(snapshot_data)}
    end
  end

  @impl Commanded.EventStore
  def record_snapshot(event_store, %Commanded.EventStore.SnapshotData{} = snapshot) do
    event_store = get_event_store(event_store)

    snapshot
    |> Mapper.to_snapshot_data()
    |> event_store.record_snapshot()
  end

  @impl Commanded.EventStore
  def delete_snapshot(event_store, source_uuid) do
    event_store = get_event_store(event_store)
    event_store.delete_snapshot(source_uuid)
  end

  defp subscription_options(start_from) do
    [
      start_from: start_from,
      mapper: &Mapper.from_recorded_event/1
    ]
  end

  defp get_event_store({_event_store, config}), do: Keyword.get(config, :event_store)

  defp verify_event_store!(event_store) do
    unless event_store do
      raise ArgumentError,
            "missing :event_store option for event store adapter in application"
    end

    unless Code.ensure_compiled?(event_store) do
      raise ArgumentError,
            "event store #{inspect(event_store)} was not compiled, " <>
              "ensure it is correct and it is included as a project dependency"
    end

    unless implements?(event_store, EventStore) do
      raise ArgumentError,
            "module #{inspect(event_store)} is not an EventStore, " <>
              "ensure you pass an event store module to the :event_store config in application"
    end
  end

  # Returns `true` if module implements behaviour.
  defp implements?(module, behaviour) do
    behaviours = Keyword.take(module.__info__(:attributes), [:behaviour])

    [behaviour] in Keyword.values(behaviours)
  end
end
