defmodule Commanded.EventStore.Adapters.EventStore do
  @moduledoc """
  EventStore adapter for Commanded
  """

  @behaviour Commanded.EventStore

  require Logger

  alias Commanded.EventStore.{
    EventData,
    RecordedEvent,
    SnapshotData,
  }

  @spec append_to_stream(String.t, non_neg_integer, list(EventData.t)) :: {:ok, non_neg_integer} | {:error, reason :: term}
  def append_to_stream(stream_uuid, expected_version, events) do
    case EventStore.append_to_stream(stream_uuid, expected_version, Enum.map(events, &to_event_data(&1))) do
      :ok -> {:ok, expected_version + length(events)}
      err -> err
    end
  end

  @spec stream_forward(String.t, non_neg_integer, non_neg_integer) :: Enumerable.t | {:error, reason :: term}
  def stream_forward(stream_uuid, start_version \\ 0, read_batch_size \\ 1_000)
  def stream_forward(stream_uuid, start_version, read_batch_size) do
    case EventStore.stream_forward(stream_uuid, start_version, read_batch_size) do
      {:error, reason} -> {:error, reason}
      stream ->	stream |> Stream.map(&from_recorded_event/1)
    end
  end

  @spec subscribe_to_all_streams(String.t, pid, :origin | :current | integer) :: {:ok, subscription :: any}
    | {:error, :subscription_already_exists}
    | {:error, reason :: term}
  def subscribe_to_all_streams(subscription_name, subscriber, start_from \\ :origin)
  def subscribe_to_all_streams(subscription_name, subscriber, start_from) do
    EventStore.subscribe_to_all_streams(subscription_name, subscriber, start_from: start_from, mapper: &from_recorded_event/1)
  end

  @spec ack_event(pid, RecordedEvent.t) :: any
  def ack_event(subscription, %RecordedEvent{event_number: event_number}) do
    EventStore.ack(subscription, event_number)
  end

  @spec unsubscribe_from_all_streams(String.t) :: :ok
  def unsubscribe_from_all_streams(subscription_name) do
    EventStore.unsubscribe_from_all_streams(subscription_name)
  end

  @spec read_snapshot(String.t) :: {:ok, SnapshotData.t} | {:error, :snapshot_not_found}
  def read_snapshot(source_uuid) do
    case EventStore.read_snapshot(source_uuid) do
      {:ok, snapshot_data} -> {:ok, from_snapshot_data(snapshot_data)}
      err -> err
    end
  end

  @spec record_snapshot(SnapshotData.t) :: :ok | {:error, reason :: term}
  def record_snapshot(%SnapshotData{} = snapshot) do
    EventStore.record_snapshot(to_snapshot_data(snapshot))
  end

  @spec delete_snapshot(String.t) :: :ok | {:error, reason :: term}
  def delete_snapshot(source_uuid) do
    EventStore.delete_snapshot(source_uuid)
  end

  def to_event_data(%EventData{} = event_data) do
    struct(EventStore.EventData, Map.from_struct(event_data))
  end

  @doc """
  Map from an event store recorded event to its Commanded equivalent
  """
  def from_recorded_event(%EventStore.RecordedEvent{
    event_id: event_id,
    stream_id: stream_id,
    stream_version: stream_version,
    correlation_id: correlation_id,
    causation_id: causation_id,
    event_type: event_type,
    data: data,
    metadata: metadata,
    created_at: created_at})
  do
    %RecordedEvent{
      event_number: event_id,
      stream_id: stream_id,
      stream_version: stream_version,
      correlation_id: correlation_id,
      causation_id: causation_id,
      event_type: event_type,
      data: data,
      metadata: metadata,
      created_at: created_at,
    }
  end

  def to_snapshot_data(%SnapshotData{} = snapshot) do
    struct(EventStore.Snapshots.SnapshotData, Map.from_struct(snapshot))
  end

  def from_snapshot_data(%EventStore.Snapshots.SnapshotData{} = snapshot_data) do
    struct(SnapshotData, Map.from_struct(snapshot_data))
  end
end
