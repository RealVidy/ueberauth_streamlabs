defmodule Ueberauth.Strategy.StreamlabsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mock
  import Plug.Conn

  setup_with_mocks([
    {OAuth2.Client, [:passthrough],
     [
       get_token: &oauth2_get_token/2,
       get: &oauth2_get/4
     ]}
  ]) do
    :ok
  end

  def set_options(routes, conn, opt) do
    case Enum.find_index(routes, &(elem(&1, 0) == {conn.request_path, conn.method})) do
      nil ->
        routes

      idx ->
        update_in(routes, [Access.at(idx), Access.elem(1), Access.elem(2)], &%{&1 | options: opt})
    end
  end

  defp token(client, opts), do: {:ok, %{client | token: OAuth2.AccessToken.new(opts)}}
  defp response(body, code \\ 200), do: {:ok, %OAuth2.Response{status_code: code, body: body}}

  def oauth2_get_token(client, code: "success_code"), do: token(client, "success_token")
  def oauth2_get_token(client, code: "uid_code"), do: token(client, "uid_token")
  def oauth2_get_token(client, code: "user_code"), do: token(client, "user_token")

  def oauth2_get(%{token: %{access_token: "success_token"}}, _url, _, _),
    do:
      response(%{
        "streamlabs" => %{
          "id" => "1234_hakuo",
          "display_name" => "Hakuo"
        }
      })

  def oauth2_get(%{token: %{access_token: "uid_token"}}, _url, _, _),
    do:
      response(%{
        "streamlabs" => %{"uid_field" => "1234_asanoyama", "display_name" => "Asanoyama"}
      })

  test "handle_request! redirects to appropriate auth uri" do
    conn = conn(:get, "/auth/streamlabs", %{})
    routes = Ueberauth.init() |> set_options(conn, default_scope: "donations.read")

    resp = Ueberauth.call(conn, routes)

    assert resp.status == 302
    assert [location] = get_resp_header(resp, "location")

    redirect_uri = URI.parse(location)
    assert redirect_uri.host == "streamlabs.com"
    assert redirect_uri.path == "/api/v1.0/authorize"

    assert %{
             "client_id" => "client_id",
             "redirect_uri" => "http://www.example.com/auth/streamlabs/callback",
             "response_type" => "code",
             "scope" => "donations.read"
           } = Plug.Conn.Query.decode(redirect_uri.query)
  end

  test "handle_callback! assigns required fields on successful auth" do
    conn = conn(:get, "/auth/streamlabs/callback", %{code: "success_code"})
    routes = Ueberauth.init([])
    assert %Plug.Conn{assigns: %{ueberauth_auth: auth}} = Ueberauth.call(conn, routes)
    assert auth.credentials.token == "success_token"
    assert auth.info.name == "Hakuo"
    assert auth.uid == "1234_hakuo"
  end

  test "uid_field is picked according to the specified option" do
    conn = conn(:get, "/auth/streamlabs/callback", %{code: "uid_code"})
    routes = Ueberauth.init() |> set_options(conn, uid_field: "uid_field")
    assert %Plug.Conn{assigns: %{ueberauth_auth: auth}} = Ueberauth.call(conn, routes)
    assert auth.info.name == "Asanoyama"
    assert auth.uid == "1234_asanoyama"
  end
end
