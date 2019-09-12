use Mix.Config

# Print only warnings and errors during test
config :logger, :console, level: :warn, format: "[$level] $message\n"

config :ex_unit, capture_log: true

config :commanded,
  assert_receive_event_timeout: 1_000,
  refute_receive_event_timeout: 1_000

config :commanded_eventstore_adapter, TestEventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "eventstore_test",
  hostname: "localhost",
  pool_size: 1,
  pool_overflow: 0
