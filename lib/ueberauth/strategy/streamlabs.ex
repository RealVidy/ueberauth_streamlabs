defmodule Ueberauth.Strategy.Streamlabs do
  @moduledoc """
  Streamlabs Strategy for Überauth.
  """

  use Ueberauth.Strategy, uid_field: :id, default_scope: "donations.read"

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles initial request for Streamlabs authentication.
  """
  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)

    params =
      [scope: scopes]
      |> with_param(:state, conn)

    opts = oauth_client_options_from_conn(conn)
    redirect!(conn, Ueberauth.Strategy.Streamlabs.OAuth.authorize_url!(params, opts))
  end

  @doc """
  Handles the callback from Streamlabs.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    params = [code: code]
    opts = oauth_client_options_from_conn(conn)

    case Ueberauth.Strategy.Streamlabs.OAuth.get_access_token(params, opts) do
      {:ok, token} ->
        fetch_user(conn, token)

      {:error, {error_code, error_description}} ->
        set_errors!(conn, [error(error_code, error_description)])
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:streamlabs_user, nil)
    |> put_private(:streamlabs_token, nil)
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    get_in(conn.private.streamlabs_user, ["streamlabs", uid_field])
  end

  @doc """
  Includes the credentials from the Streamlabs response.
  """
  def credentials(conn) do
    token = conn.private.streamlabs_token
    scope_string = token.other_params["scope"] || ""
    scopes = String.split(scope_string, ",")

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      token_type: Map.get(token, :token_type),
      refresh_token: token.refresh_token,
      token: token.access_token
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.streamlabs_user["streamlabs"]

    %Info{
      name: user["display_name"]
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the Streamlabs callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.streamlabs_token,
        user: conn.private.streamlabs_user
      }
    }
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :streamlabs_token, token)

    path = "https://streamlabs.com/api/v1.0/user"
    resp = Ueberauth.Strategy.Streamlabs.OAuth.get(token, path)

    case resp do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
      when status_code in 200..399 ->
        put_private(conn, :streamlabs_user, user)

      {:error, %OAuth2.Response{status_code: status_code}} ->
        set_errors!(conn, [error("OAuth2", Integer.to_string(status_code))])

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp with_param(params, key, conn) do
    if value = conn.params[to_string(key)], do: Keyword.put(params, key, value), else: params
  end

  defp oauth_client_options_from_conn(conn) do
    base_options = [redirect_uri: callback_url(conn)]
    request_options = conn.private[:ueberauth_request_options].options

    case {request_options[:client_id], request_options[:client_secret]} do
      {nil, _} -> base_options
      {_, nil} -> base_options
      {id, secret} -> [client_id: id, client_secret: secret] ++ base_options
    end
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end
