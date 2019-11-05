defmodule Commanded.EventStore.Adapters.EventStore.Mapper do
  @moduledoc false

  def to_event_data(%Commanded.EventStore.EventData{} = event_data) do
    %Commanded.EventStore.EventData{
      causation_id: causation_id,
      correlation_id: correlation_id,
      event_type: event_type,
      data: data,
      metadata: metadata
    } = event_data

    %EventStore.EventData{
      causation_id: causation_id,
      correlation_id: correlation_id,
      event_type: event_type,
      data: data,
      metadata: metadata
    }
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
    %Commanded.EventStore.SnapshotData{
      source_uuid: source_uuid,
      source_version: source_version,
      source_type: source_type,
      data: data,
      metadata: metadata,
      created_at: created_at
    } = snapshot

    %EventStore.Snapshots.SnapshotData{
      source_uuid: source_uuid,
      source_version: source_version,
      source_type: source_type,
      data: data,
      metadata: metadata,
      created_at: created_at
    }
  end

  def from_snapshot_data(%EventStore.Snapshots.SnapshotData{} = snapshot) do
    %EventStore.Snapshots.SnapshotData{
      source_uuid: source_uuid,
      source_version: source_version,
      source_type: source_type,
      data: data,
      metadata: metadata,
      created_at: created_at
    } = snapshot

    %Commanded.EventStore.SnapshotData{
      source_uuid: source_uuid,
      source_version: source_version,
      source_type: source_type,
      data: data,
      metadata: metadata,
      created_at: created_at
    }
  end
end
