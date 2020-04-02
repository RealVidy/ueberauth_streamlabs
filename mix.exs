defmodule UeberauthStreamlabs.MixProject do
  use Mix.Project

  @version "0.1.0"
  # @url "https://github.com/ueberauth/ueberauth_google"

  def project do
    [
      app: :ueberauth_streamlabs,
      version: @version,
      name: "Ueberauth Streamlabs Strategy",
      package: package(),
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      # source_url: @url,
      # homepage_url: @url,
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
      {:ueberauth, "~> 0.6.0"}
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
      maintainers: ["Victor Degliame"],
      licenses: ["MIT"]
      # links: %{GitHub: @url}
    ]
  end
end
