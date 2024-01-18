import Config

config :commanded,
  assert_receive_event_timeout: 1_000,
  refute_receive_event_timeout: 1_000

config :commanded_eventstore_adapter, event_stores: [TestEventStore]

config :commanded_eventstore_adapter, TestEventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "eventstore_test",
  hostname: "localhost",
  pool_size: 5,
  pool_overflow: 0

config :ex_unit,
  assert_receive_timeout: 1_000,
  capture_log: [level: :warning]

# Print only warning and above log messages during tests
config :logger, :console, level: :warning, format: "[$level] $message\n"
