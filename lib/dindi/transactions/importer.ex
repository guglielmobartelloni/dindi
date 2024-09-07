defmodule Dindi.Transactions.Importer do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://bankaccountdata.gocardless.com/api/v2"
  plug Tesla.Middleware.FollowRedirects
  plug Tesla.Middleware.Cache, ttl: :timer.minutes(100)

  plug Tesla.Middleware.Headers, [
    {"accept", "application/json"},
    {"Content-Type", "application/json"}
  ]

  plug Tesla.Middleware.JSON

  def new() do
    token = get_token()

    Tesla.client([
      {Tesla.Middleware.BearerAuth, token: token}
    ])
  end

  def list_banks(client, country \\ "it") do
    get!(client, "/institutions", query: [country: country]).body
  end

  def create_link(client, redirect_url, institution_id, user_language \\ "EN") do
    {:ok, response} =
      post(client, "/requisitions", %{
        redirect: redirect_url,
        institution_id: institution_id,
        user_language: user_language
      })

    response.body
  end

  def list_accounts(client, requisition_id) do
    {:ok, response} =
      get(client, "/requisitions/" <> requisition_id)

    response.body
  end

  def account_info(client, account_id) do
    {:ok, response} =
      get(client, "/accounts/" <> account_id)

    response.body
  end

  def list_transactions(client, account_id) do
    {:ok, response} =
      get(client, "/accounts/" <> account_id <> "/transactions/")

    response.body
  end

  def get_token() do
    gocardless_secret_id = System.get_env("GOCARDLESS_SECRET_ID")
    gocardless_secret_key = System.get_env("GOCARDLESS_SECRET_KEY")

    {:ok, response} =
      post(
        "/token/new",
        %{secret_id: gocardless_secret_id, secret_key: gocardless_secret_key}
      )

    %{"access" => token} = response.body
    token
  end
end
