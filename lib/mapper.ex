defmodule Commanded.EventStore.Adapters.EventStore.Mapper do
  @moduledoc false

  def to_event_data(%Commanded.EventStore.EventData{} = event_data) do
    struct(EventStore.EventData, Map.from_struct(event_data))
  end

  def from_recorded_event(%EventStore.RecordedEvent{} = event) do
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

    %Commanded.EventStore.RecordedEvent{
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

  def to_snapshot_data(%Commanded.EventStore.SnapshotData{} = snapshot) do
    struct(EventStore.Snapshots.SnapshotData, Map.from_struct(snapshot))
  end

  def from_snapshot_data(%EventStore.Snapshots.SnapshotData{} = snapshot_data) do
    struct(Commanded.EventStore.SnapshotData, Map.from_struct(snapshot_data))
  end
end
