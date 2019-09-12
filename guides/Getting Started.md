# Getting started

The package can be installed from hex as follows.

1. Add `commanded_eventstore_adapter` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:commanded_eventstore_adapter, "~> 0.6"}]
    end
    ```

2. Create an event store for your application:

    ```elixir
    defmodule MyApp.EventStore do
      use EventStore, otp_app: :my_app
    end
    ```

3. Define and configure your Commanded application to use the `Commanded.EventStore.Adapters.EventStore` adapter and your own event store module:

    ```elixir
    defmodule MyApp.Application do
      use Commanded.Application,
        otp_app: :my_app,
        event_store: [
          adapter: Commanded.EventStore.Adapters.EventStore,
          event_store: MyApp.EventStore
        ]
      end
    ```

4. Configure the event store in each environment's mix config file (e.g. `config/dev.exs`), specifying usage of the included JSON serializer:

    ```elixir
    config :my_app, MyApp.EventStore,
      serializer: Commanded.Serialization.JsonSerializer,
      username: "postgres",
      password: "postgres",
      database: "eventstore_dev",
      hostname: "localhost",
      pool_size: 10
    ```

5. Add your event store to `config/config.exs` to make it easier to use the event store mix tasks:

    ```elixir
    # config/config.exs
    config :my_app, event_stores: [MyApp.EventStore]
    ```

6. Create the `eventstore` database and tables using the `mix` task:

    ```console
    $ mix do event_store.create, event_store.init
    ```
