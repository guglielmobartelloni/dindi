defmodule DindiWeb.AccountsLive.New do
  alias Dindi.Accounts
  use DindiWeb, :live_view



  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, Accounts.change_account(%Dindi.Accounts.Account{}) |> to_form())

    {:ok, socket}
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
         |> put_flash(:info, "Account created successfully!")
         |> push_navigate(to: ~p"/accounts")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end
  
end
