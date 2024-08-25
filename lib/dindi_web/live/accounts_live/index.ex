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
      |> assign(:form, Accounts.change_account(%Dindi.Accounts.Account{}) |> to_form())

    {:ok, socket}
  end

  @impl true
  def handle_event("filter-date", %{"start_date" => start_date, "end_date" => end_date}, socket) do
    IO.inspect(start_date <> " " <> end_date)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"account" => account_params}, socket) do
    form =
      %Dindi.Accounts.Account{}
      |> Accounts.change_account(account_params)
      |> to_form(action: :validate)

    socket = socket |> assign(form: form)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"account" => account_params}, socket) do
    case Accounts.create_account(account_params) do
      {:ok, _account} ->
        {:noreply,
         socket
         |> assign(:accounts, Accounts.list_accounts())
         |> assign(:form, Accounts.change_account(%Dindi.Accounts.Account{}) |> to_form())
         |> put_flash(:info, "Account created successfully!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end

  @impl true
  def handle_event("delete-account", %{"id" => id}, socket) do
    to_be_deleted_account = Accounts.get_account!(id)

    case Accounts.delete_account(to_be_deleted_account) do
      {:ok, transaction} ->
        IO.inspect(transaction)

        {:noreply,
         socket
         |> assign(:accounts, Accounts.list_accounts())
         |> put_flash(:info, "Account deleted successfully!")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Something went wrong")}
    end
  end
end
