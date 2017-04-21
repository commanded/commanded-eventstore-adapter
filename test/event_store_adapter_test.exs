# execute event store adapter tests from Commanded
Code.require_file "../deps/commanded/test/event_store_adapter/append_events_test.exs", __DIR__
Code.require_file "../deps/commanded/test/event_store_adapter/snapshot_test.exs", __DIR__
Code.require_file "../deps/commanded/test/event_store_adapter/subscription_test.exs", __DIR__
