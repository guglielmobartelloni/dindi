defmodule DindiWeb.TransactionLive.New do
  alias Ecto.Adapter.Transaction
  use DindiWeb, :live_view

  alias Dindi.Transactions
  alias Dindi.Transactions.Transaction

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, Transactions.change_transaction(%Transaction{}) |> to_form())

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    form =
      %Transaction{}
      |> Transactions.change_transaction(transaction_params)
      |> to_form(action: :validate)
      |> IO.inspect()

    socket = socket |> assign(form: form)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    case Transactions.create_transaction(transaction_params) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully!")
         |> push_navigate(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end
end
