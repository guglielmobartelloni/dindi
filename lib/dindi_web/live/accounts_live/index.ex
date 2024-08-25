defmodule DindiWeb.AccountsLive.Index do
  use DindiWeb, :live_view

  alias Dindi.Accounts

  @impl true
  def mount(_params, _session, socket) do
    accounts = Accounts.list_accounts()

    socket =
      socket
      |> assign(:accounts, accounts)
      |> assign(:date_form, to_form(%{start_date: "", end_date: ""}))

    {:ok, socket}
  end

  @impl true
  def handle_event("filter-date", %{"start_date" => start_date, "end_date" => end_date}, socket) do
    IO.inspect(start_date <> " " <> end_date)

    {:noreply, socket}
  end
end
