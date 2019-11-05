defmodule Commanded.EventStore.Adapters.EventStore do
  @moduledoc false

  alias Commanded.EventStore.Adapters.EventStore.Mapper

  @behaviour Commanded.EventStore.Adapter

  @all_stream "$all"

  @impl Commanded.EventStore.Adapter
  def child_spec(application, config) do
    event_store = Keyword.get(config, :event_store)

    verify_event_store!(application, event_store)

    {:ok, [event_store], %{event_store: event_store}}
  end

  @impl Commanded.EventStore.Adapter
  def append_to_stream(adapter_meta, stream_uuid, expected_version, events) do
    event_store = get_event_store(adapter_meta)

    event_store.append_to_stream(
      stream_uuid,
      expected_version,
      Enum.map(events, &Mapper.to_event_data/1)
    )
  end

  @impl Commanded.EventStore.Adapter
  def stream_forward(adapter_meta, stream_uuid, start_version \\ 0, read_batch_size \\ 1_000) do
    event_store = get_event_store(adapter_meta)

    case event_store.stream_forward(stream_uuid, start_version, read_batch_size) do
      {:error, error} -> {:error, error}
      stream -> Stream.map(stream, &Mapper.from_recorded_event/1)
    end
  end

  @impl Commanded.EventStore.Adapter
  def subscribe(adapter_meta, :all), do: subscribe(adapter_meta, @all_stream)

  @impl Commanded.EventStore.Adapter
  def subscribe(adapter_meta, stream_uuid) do
    event_store = get_event_store(adapter_meta)

    event_store.subscribe(stream_uuid, mapper: &Mapper.from_recorded_event/1)
  end

  @impl Commanded.EventStore.Adapter
  def subscribe_to(adapter_meta, :all, subscription_name, subscriber, start_from) do
    event_store = get_event_store(adapter_meta)

    event_store.subscribe_to_all_streams(
      subscription_name,
      subscriber,
      subscription_options(start_from)
    )
  end

  @impl Commanded.EventStore.Adapter
  def subscribe_to(adapter_meta, stream_uuid, subscription_name, subscriber, start_from) do
    event_store = get_event_store(adapter_meta)

    event_store.subscribe_to_stream(
      stream_uuid,
      subscription_name,
      subscriber,
      subscription_options(start_from)
    )
  end

  @impl Commanded.EventStore.Adapter
  def ack_event(adapter_meta, subscription, %Commanded.EventStore.RecordedEvent{} = event) do
    %Commanded.EventStore.RecordedEvent{event_number: event_number} = event

    event_store = get_event_store(adapter_meta)

    event_store.ack(subscription, event_number)
  end

  @impl Commanded.EventStore.Adapter
  def unsubscribe(_adapter_meta, subscription) do
    EventStore.Subscriptions.Subscription.unsubscribe(subscription)
  end

  @impl Commanded.EventStore.Adapter
  def delete_subscription(adapter_meta, :all, subscription_name) do
    event_store = get_event_store(adapter_meta)

    event_store.delete_subscription(@all_stream, subscription_name)
  end

  @impl Commanded.EventStore.Adapter
  def delete_subscription(adapter_meta, stream_uuid, subscription_name) do
    event_store = get_event_store(adapter_meta)

    event_store.delete_subscription(stream_uuid, subscription_name)
  end

  @impl Commanded.EventStore.Adapter
  def read_snapshot(adapter_meta, source_uuid) do
    event_store = get_event_store(adapter_meta)

    with {:ok, snapshot_data} <- event_store.read_snapshot(source_uuid) do
      {:ok, Mapper.from_snapshot_data(snapshot_data)}
    end
  end

  @impl Commanded.EventStore.Adapter
  def record_snapshot(adapter_meta, %Commanded.EventStore.SnapshotData{} = snapshot) do
    event_store = get_event_store(adapter_meta)

    snapshot
    |> Mapper.to_snapshot_data()
    |> event_store.record_snapshot()
  end

  @impl Commanded.EventStore.Adapter
  def delete_snapshot(adapter_meta, source_uuid) do
    event_store = get_event_store(adapter_meta)

    event_store.delete_snapshot(source_uuid)
  end

  defp subscription_options(start_from) do
    [
      start_from: start_from,
      mapper: &Mapper.from_recorded_event/1
    ]
  end

  defp get_event_store(adapter_meta), do: Map.get(adapter_meta, :event_store)

  defp verify_event_store!(application, event_store) do
    unless event_store do
      raise ArgumentError,
            "missing :event_store option for event store adapter in application " <>
              inspect(application)
    end

    unless Code.ensure_compiled?(event_store) do
      raise ArgumentError,
            "event store " <>
              inspect(event_store) <>
              " was not compiled, " <>
              "ensure it is correct and it is included as a project dependency"
    end

    unless implements?(event_store, EventStore) do
      raise ArgumentError,
            "module " <>
              inspect(event_store) <>
              " is not an EventStore, " <>
              "ensure you pass an event store module to the :event_store config in application " <>
              inspect(application)
    end
  end

  # Returns `true` if module implements behaviour.
  defp implements?(module, behaviour) do
    behaviours = Keyword.take(module.__info__(:attributes), [:behaviour])

    [behaviour] in Keyword.values(behaviours)
  end
end
