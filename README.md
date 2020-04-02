# Überauth Streamlabs

> Streamlabs OAuth2 strategy for Überauth.

## Disclaimer

This is an early draft of the Streamlabs strategy. Please be advised that it will probably not be perfect.

Pull requests and feedback are definitely welcome!

## Installation

1. Setup your application at [Register an Application](https://streamlabs.com/dashboard/#/apps/register).

1. Add `:ueberauth_streamlabs` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_streamlabs, git: "https://github.com/RealVidy/ueberauth_streamlabs"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_streamlabs]]
    end
    ```

1. Add Streamlabs to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        streamlabs: {Ueberauth.Strategy.Streamlabs, []}
      ]
    ```

1.  Update your provider configuration:

    Use that if you want to read client ID/secret from the environment 
    variables in the compile time:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Streamlabs.OAuth,
      client_id: System.get_env("STREAMLABS_CLIENT_ID"),
      client_secret: System.get_env("STREAMLABS_CLIENT_SECRET")
    ```

    Use that if you want to read client ID/secret from the environment 
    variables in the run time:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Streamlabs.OAuth,
      client_id: {System, :get_env, ["STREAMLABS_CLIENT_ID"]},
      client_secret: {System, :get_env, ["STREAMLABS_CLIENT_SECRET"]}
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initiate the request through:

    /auth/streamlabs

Or with options:

    /auth/streamlabs?scope=donations.read

By default the requested scope is "donations.read". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    streamlabs: {Ueberauth.Strategy.Streamlabs, [default_scope: "donations.read donations.create"]}
  ]
```

See [streamlabs scopes](https://streamlabs.readme.io/docs/scopes)

## License

Please see [LICENSE](https://github.com/ueberauth/ueberauth_streamlabs/blob/master/LICENSE) for licensing details.
