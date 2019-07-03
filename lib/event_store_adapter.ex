defmodule Commanded.EventStore.Adapters.EventStore do
  @moduledoc """
  [EventStore](https://github.com/commanded/eventstore) adapter for
  [Commanded](https://github.com/commanded/commanded).
  """

  alias Commanded.EventStore.Adapters.EventStore.Mapper

  @behaviour Commanded.EventStore

  @all_stream "$all"

  @impl Commanded.EventStore
  def child_spec, do: []

  @impl Commanded.EventStore
  def append_to_stream(stream_uuid, expected_version, events) do
    EventStore.append_to_stream(
      stream_uuid,
      expected_version,
      Enum.map(events, &Mapper.to_event_data/1)
    )
  end

  @impl Commanded.EventStore
  def stream_forward(stream_uuid, start_version \\ 0, read_batch_size \\ 1_000) do
    case EventStore.stream_forward(stream_uuid, start_version, read_batch_size) do
      {:error, error} -> {:error, error}
      stream -> Stream.map(stream, &Mapper.from_recorded_event/1)
    end
  end

  @impl Commanded.EventStore
  def subscribe(:all), do: subscribe(@all_stream)

  @impl Commanded.EventStore
  def subscribe(stream_uuid) do
    EventStore.subscribe(stream_uuid, mapper: &Mapper.from_recorded_event/1)
  end

  @impl Commanded.EventStore
  def subscribe_to(:all, subscription_name, subscriber, start_from) do
    EventStore.subscribe_to_all_streams(
      subscription_name,
      subscriber,
      subscription_options(start_from)
    )
  end

  @impl Commanded.EventStore
  def subscribe_to(stream_uuid, subscription_name, subscriber, start_from) do
    EventStore.subscribe_to_stream(
      stream_uuid,
      subscription_name,
      subscriber,
      subscription_options(start_from)
    )
  end

  @impl Commanded.EventStore
  def ack_event(subscription, %Commanded.EventStore.RecordedEvent{} = event) do
    %Commanded.EventStore.RecordedEvent{event_number: event_number} = event

    EventStore.ack(subscription, event_number)
  end

  @impl Commanded.EventStore
  def unsubscribe(subscription) do
    EventStore.Subscriptions.Subscription.unsubscribe(subscription)
  end

  @impl Commanded.EventStore
  def delete_subscription(:all, subscription_name) do
    EventStore.delete_subscription(@all_stream, subscription_name)
  end

  @impl Commanded.EventStore
  def delete_subscription(stream_uuid, subscription_name) do
    EventStore.delete_subscription(stream_uuid, subscription_name)
  end

  @impl Commanded.EventStore
  def read_snapshot(source_uuid) do
    with {:ok, snapshot_data} <- EventStore.read_snapshot(source_uuid) do
      {:ok, Mapper.from_snapshot_data(snapshot_data)}
    end
  end

  @impl Commanded.EventStore
  def record_snapshot(%Commanded.EventStore.SnapshotData{} = snapshot) do
    snapshot
    |> Mapper.to_snapshot_data()
    |> EventStore.record_snapshot()
  end

  @impl Commanded.EventStore
  def delete_snapshot(source_uuid) do
    EventStore.delete_snapshot(source_uuid)
  end

  defp subscription_options(start_from) do
    [
      start_from: start_from,
      mapper: &Mapper.from_recorded_event/1
    ]
  end
end
