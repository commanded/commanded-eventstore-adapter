defmodule Commanded.EventStore.Adapters.EventStore do
  @moduledoc """
  [EventStore](https://github.com/commanded/eventstore) adapter for
  [Commanded](https://github.com/commanded/commanded).
  """

  @behaviour Commanded.EventStore

  @all_stream "$all"

  alias Commanded.EventStore.{EventData, RecordedEvent, SnapshotData}

  @impl Commanded.EventStore
  def child_spec, do: []

  @impl Commanded.EventStore
  def append_to_stream(stream_uuid, expected_version, events) do
    EventStore.append_to_stream(
      stream_uuid,
      expected_version,
      Enum.map(events, &to_event_data/1)
    )
  end

  @impl Commanded.EventStore
  def stream_forward(stream_uuid, start_version \\ 0, read_batch_size \\ 1_000)

  def stream_forward(stream_uuid, start_version, read_batch_size) do
    case EventStore.stream_forward(stream_uuid, start_version, read_batch_size) do
      {:error, error} -> {:error, error}
      stream -> Stream.map(stream, &from_recorded_event/1)
    end
  end

  @impl Commanded.EventStore
  def subscribe(stream_uuid)

  def subscribe(:all), do: subscribe(@all_stream)

  def subscribe(stream_uuid) do
    EventStore.subscribe(stream_uuid, mapper: &from_recorded_event/1)
  end

  @impl Commanded.EventStore
  def subscribe_to(stream_uuid, subscription_name, subscriber, start_from \\ :origin)

  def subscribe_to(:all, subscription_name, subscriber, start_from) do
    EventStore.subscribe_to_all_streams(
      subscription_name,
      subscriber,
      start_from: start_from,
      mapper: &from_recorded_event/1
    )
  end

  def subscribe_to(stream_uuid, subscription_name, subscriber, start_from) do
    EventStore.subscribe_to_stream(
      stream_uuid,
      subscription_name,
      subscriber,
      start_from: start_from,
      mapper: &from_recorded_event/1
    )
  end

  @impl Commanded.EventStore
  def ack_event(subscription, %RecordedEvent{event_number: event_number}) do
    EventStore.ack(subscription, event_number)
  end

  @impl Commanded.EventStore
  def unsubscribe(subscription) do
    EventStore.Subscriptions.Subscription.unsubscribe(subscription)
  end

  @impl Commanded.EventStore
  def delete_subscription(:all, subscription_name),
    do: delete_subscription(@all_stream, subscription_name)

  def delete_subscription(stream_uuid, subscription_name) do
    EventStore.delete_subscription(stream_uuid, subscription_name)
  end

  @impl Commanded.EventStore
  def read_snapshot(source_uuid) do
    case EventStore.read_snapshot(source_uuid) do
      {:ok, snapshot_data} -> {:ok, from_snapshot_data(snapshot_data)}
      err -> err
    end
  end

  @impl Commanded.EventStore
  def record_snapshot(%SnapshotData{} = snapshot) do
    EventStore.record_snapshot(to_snapshot_data(snapshot))
  end

  @impl Commanded.EventStore
  def delete_snapshot(source_uuid) do
    EventStore.delete_snapshot(source_uuid)
  end

  defp to_event_data(%EventData{} = event_data) do
    struct(EventStore.EventData, Map.from_struct(event_data))
  end

  defp from_recorded_event(%EventStore.RecordedEvent{} = event) do
    %EventStore.RecordedEvent{
      event_id: event_id,
      event_number: event_number,
      stream_uuid: stream_uuid,
      stream_version: stream_version,
      correlation_id: correlation_id,
      causation_id: causation_id,
      event_type: event_type,
      data: data,
      metadata: metadata,
      created_at: created_at
    } = event

    %RecordedEvent{
      event_id: event_id,
      event_number: event_number,
      stream_id: stream_uuid,
      stream_version: stream_version,
      correlation_id: correlation_id,
      causation_id: causation_id,
      event_type: event_type,
      data: data,
      metadata: metadata,
      created_at: created_at
    }
  end

  defp to_snapshot_data(%SnapshotData{} = snapshot) do
    struct(EventStore.Snapshots.SnapshotData, Map.from_struct(snapshot))
  end

  defp from_snapshot_data(%EventStore.Snapshots.SnapshotData{} = snapshot_data) do
    struct(SnapshotData, Map.from_struct(snapshot_data))
  end
end
