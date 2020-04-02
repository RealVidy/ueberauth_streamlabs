use Mix.Config

config :ueberauth, Ueberauth,
  providers: [
    streamlabs: {Ueberauth.Strategy.Streamlabs, []}
  ]

config :ueberauth, Ueberauth.Strategy.Streamlabs.OAuth,
  client_id: "client_id",
  client_secret: "client_secret",
  token_url: "token_url"
