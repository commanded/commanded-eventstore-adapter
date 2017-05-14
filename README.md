# EventStore adapter for Commanded

Use the PostgreSQL-based [EventStore](https://github.com/slashdotdash/eventstore) with [Commanded](https://github.com/slashdotdash/commanded).

## Getting started

The package can be installed from hex as follows.

  1. Add `commanded_eventstore_adapter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:commanded_eventstore_adapter, "~> 0.1"}]
end
```

  2. Configure Commanded to use the event store adapter:

```elixir
config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore
```

  3. Configure the `eventstore` in each environment's mix config file (e.g. `config/dev.exs`), specifying usage of the included JSON serializer:

```elixir
config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "eventstore_dev",
  hostname: "localhost",
  pool_size: 10
```

  4. Create the `eventstore` database and tables using the `mix` task.

```
mix event_store.create
```
