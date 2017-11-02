# EventStore adapter for Commanded

Use the PostgreSQL-based [EventStore](https://github.com/commanded/eventstore) with [Commanded](https://github.com/commanded/commanded).

[Changelog](CHANGELOG.md)

MIT License

[![Build Status](https://travis-ci.org/commanded/commanded-eventstore-adapter.svg?branch=master)](https://travis-ci.org/commanded/commanded-eventstore-adapter)

## Getting started

The package can be installed from hex as follows.

1. Add `commanded_eventstore_adapter` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:commanded_eventstore_adapter, "~> 0.3"}]
    end
    ```

2. Include `:eventstore` in the list of extra applications to start.

    ```elixir
    def application do
      [
        extra_applications: [
          :logger,
          :eventstore,
        ],
      ]
    end
    ```

3. Configure Commanded to use the EventStore adapter:

    ```elixir
    config :commanded,
      event_store_adapter: Commanded.EventStore.Adapters.EventStore
    ```

4. Configure the `eventstore` in each environment's mix config file (e.g. `config/dev.exs`), specifying usage of the included JSON serializer:

    ```elixir
    config :eventstore, EventStore.Storage,
      serializer: Commanded.Serialization.JsonSerializer,
      username: "postgres",
      password: "postgres",
      database: "eventstore_dev",
      hostname: "localhost",
      pool_size: 10
    ```

5. Create the `eventstore` database and tables using the `mix` task:

    ```console
    $ mix event_store.create
    ```
