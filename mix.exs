defmodule UeberauthStreamlabs.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/RealVidy/ueberauth_streamlabs"

  def project do
    [
      app: :ueberauth_streamlabs,
      version: @version,
      name: "Ueberauth Streamlabs Strategy",
      package: package(),
      elixir: "~> 1.9",
      source_url: @url,
      homepage_url: @url,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oauth2, "~> 1.0 or ~> 2.0"},
      {:ueberauth, "~> 0.6.0"},
      {:mock, "~> 0.3", only: :test}
    ]
  end

  defp docs do
    [extras: ["README.md", "CONTRIBUTING.md"]]
  end

  defp description do
    "An Uberauth strategy for Streamlabs authentication."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Victor 'RealVidy' Degliame"],
      licenses: ["MIT"],
      links: %{GitHub: @url}
    ]
  end
end
