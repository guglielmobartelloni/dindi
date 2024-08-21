defmodule DindiWeb.TransactionLive.New do
  alias Dindi.Accounts
  alias Ecto.Adapter.Transaction
  use DindiWeb, :live_view

  alias Dindi.Transactions
  alias Dindi.Transactions.Transaction

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container-md mx-auto">
      <div class="card w-96 bg-white shadow-xl p-6 mx-auto">
        <.simple_form for={@form} phx-change="validate" phx-submit="save" class="card">
          <.input field={@form[:description]} label="Description" />
          <.input field={@form[:date]} type="date" value={Date.utc_today()} label="Transaction Date" />

          <.input field={@form[:category_id]} label="Categories" type="select" options={@categories} />
          <.input field={@form[:account_id]} label="Account" type="select" options={@accounts} />

          <.input field={@form[:amount]} type="number" label="Amount" />
          <:actions>
            <.button class="btn-primary">Save</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form, Transactions.change_transaction(%Transaction{}) |> to_form())
      |> assign(:categories, Transactions.list_categories() |> to_options)
      |> assign(:accounts, Accounts.list_accounts() |> to_options)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    form =
      %Transaction{}
      |> Transactions.change_transaction(transaction_params)
      |> to_form(action: :validate)

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

  defp to_options(db_list) do
    Enum.map(db_list, &{&1.name, &1.id})
  end
end
