defmodule Commanded.EventStore.Adapters.EventStore.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :commanded_eventstore_adapter,
      version: @version,
      elixir: "~> 1.5",
      description: description(),
      docs: docs(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :eventstore
      ]
    ]
  end

  defp deps do
    [
      {:commanded, ">= 0.16.0", runtime: false},
      {:eventstore, ">= 0.14.0"},
      {:ex_doc, "~> 0.17", only: :dev},
      {:mix_test_watch, "~> 0.5", only: :dev}
    ]
  end

  defp description do
    """
    EventStore adapter for Commanded
    """
  end

  defp docs do
    [
      main: "Commanded.EventStore.Adapters.EventStore",
      canonical: "http://hexdocs.pm/commanded_eventstore_adapter",
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      maintainers: ["Ben Smith"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/commanded/commanded-eventstore-adapter",
        "Docs" => "https://hexdocs.pm/commanded_eventstore_adapter/"
      }
    ]
  end
end
