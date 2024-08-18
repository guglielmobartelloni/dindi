defmodule DindiWeb.AccountsLive.Index do
  use DindiWeb, :live_view

  alias Dindi.Accounts

  @impl true
  def mount(_params, _session, socket) do
    accounts = Accounts.list_accounts()

    socket =
      socket
      |> assign(:accounts, accounts)

    {:ok, socket}
  end
end
