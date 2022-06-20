defmodule Commanded.EventStore.Adapters.EventStore do
  @moduledoc """
  EventStore adapter for Commanded.

  Please check the [Getting Started](getting-started.html) guide to learn more.
  """

  alias Commanded.EventStore.Adapters.EventStore.Mapper

  @behaviour Commanded.EventStore.Adapter

  @all_stream "$all"

  @impl Commanded.EventStore.Adapter
  def child_spec(application, config) do
    {event_store, config} = Keyword.pop(config, :event_store)

    verify_event_store!(application, event_store)

    name = Keyword.get(config, :name, event_store)

    # Rename `prefix` config to `schema`
    config =
      case Keyword.pop(config, :prefix) do
        {nil, config} -> config
        {prefix, config} -> Keyword.put(config, :schema, prefix)
      end

    child_spec = [{event_store, config}]
    adapter_meta = %{event_store: event_store, name: name}

    {:ok, child_spec, adapter_meta}
  end

  @impl Commanded.EventStore.Adapter
  def append_to_stream(adapter_meta, stream_uuid, expected_version, events) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    events = Enum.map(events, &Mapper.to_event_data/1)

    event_store.append_to_stream(stream_uuid, expected_version, events, name: name)
  end

  @impl Commanded.EventStore.Adapter
  def stream_forward(adapter_meta, stream_uuid, start_version \\ 0, read_batch_size \\ 1_000) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    opts = [name: name, read_batch_size: read_batch_size]

    case event_store.stream_forward(stream_uuid, start_version, opts) do
      {:error, error} -> {:error, error}
      stream -> Stream.map(stream, &Mapper.from_recorded_event/1)
    end
  end

  @impl Commanded.EventStore.Adapter
  def subscribe(adapter_meta, :all), do: subscribe(adapter_meta, @all_stream)

  @impl Commanded.EventStore.Adapter
  def subscribe(adapter_meta, stream_uuid) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    event_store.subscribe(stream_uuid, name: name, mapper: &Mapper.from_recorded_event/1)
  end

  @impl Commanded.EventStore.Adapter
  def subscribe_to(adapter_meta, :all, subscription_name, subscriber, start_from, opts) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    event_store.subscribe_to_all_streams(
      subscription_name,
      subscriber,
      subscription_options(name, start_from, opts)
    )
  end

  @impl Commanded.EventStore.Adapter
  def subscribe_to(adapter_meta, stream_uuid, subscription_name, subscriber, start_from, opts) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    event_store.subscribe_to_stream(
      stream_uuid,
      subscription_name,
      subscriber,
      subscription_options(name, start_from, opts)
    )
  end

  @impl Commanded.EventStore.Adapter
  def ack_event(adapter_meta, subscription, %Commanded.EventStore.RecordedEvent{} = event) do
    %Commanded.EventStore.RecordedEvent{event_number: event_number} = event

    {event_store, _name} = extract_adapter_meta(adapter_meta)

    event_store.ack(subscription, event_number)
  end

  @impl Commanded.EventStore.Adapter
  def unsubscribe(_adapter_meta, subscription) do
    EventStore.Subscriptions.Subscription.unsubscribe(subscription)
  end

  @impl Commanded.EventStore.Adapter
  def delete_subscription(adapter_meta, :all, subscription_name) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    event_store.delete_subscription(@all_stream, subscription_name, name: name)
  end

  @impl Commanded.EventStore.Adapter
  def delete_subscription(adapter_meta, stream_uuid, subscription_name) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    event_store.delete_subscription(stream_uuid, subscription_name, name: name)
  end

  @impl Commanded.EventStore.Adapter
  def read_snapshot(adapter_meta, source_uuid) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    with {:ok, snapshot_data} <- event_store.read_snapshot(source_uuid, name: name) do
      snapshot = Mapper.from_snapshot_data(snapshot_data)

      {:ok, snapshot}
    end
  end

  @impl Commanded.EventStore.Adapter
  def record_snapshot(adapter_meta, %Commanded.EventStore.SnapshotData{} = snapshot) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    snapshot
    |> Mapper.to_snapshot_data()
    |> event_store.record_snapshot(name: name)
  end

  @impl Commanded.EventStore.Adapter
  def delete_snapshot(adapter_meta, source_uuid) do
    {event_store, name} = extract_adapter_meta(adapter_meta)

    event_store.delete_snapshot(source_uuid, name: name)
  end

  defp subscription_options(name, start_from, opts) do
    opts
    |> Keyword.merge(
      name: name,
      start_from: start_from,
      mapper: &Mapper.from_recorded_event/1
    )
    |> Keyword.update(:partition_by, nil, fn
      nil ->
        nil

      partition_by when is_function(partition_by, 1) ->
        fn %EventStore.RecordedEvent{} = event ->
          Mapper.from_recorded_event(event) |> partition_by.()
        end
    end)
  end

  defp extract_adapter_meta(adapter_meta) do
    event_store = Map.fetch!(adapter_meta, :event_store)
    name = Map.fetch!(adapter_meta, :name)

    {event_store, name}
  end

  defp verify_event_store!(application, event_store) do
    unless event_store do
      raise ArgumentError,
            "missing :event_store option for event store adapter in application " <>
              inspect(application)
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
