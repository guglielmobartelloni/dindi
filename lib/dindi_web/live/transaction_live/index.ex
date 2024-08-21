defmodule DindiWeb.TransactionLive.Index do
  use DindiWeb, :live_view

  alias Dindi.Accounts
  alias Ecto.Adapter.Transaction
  alias Dindi.Transactions.Transaction
  alias Dindi.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container-md mx-auto mb-5">
      <div class="card bg-white shadow-xl p-6 mx-auto">
        <.form for={@form} phx-change="validate" phx-submit="save" class="card grid grid-cols-6 gap-4 content-evenly">
          <.input field={@form[:description]} label="Description" />
          <.input field={@form[:date]} type="date" value={Date.utc_today()} label="Transaction" />

          <.input field={@form[:category_id]} label="Categories" type="select" options={@categories} />
          <.input field={@form[:account_id]} label="Account" type="select" options={@accounts} />

          <.input field={@form[:amount]} type="number" label="Amount" />

          <.button class="btn-primary col-2">Save</.button>
        </.form>
      </div>
    </div>

    <div class="container-md mx-auto">
      <.header>
        <h1 class="text-3xl font-semibold leading-normal">Transactions</h1>
        <:actions>
          <.link navigate={~p"/transactions/new"}>
            <.button class="mb-5">New Transaction</.button>
          </.link>
        </:actions>
      </.header>

      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400">
          <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
              <th scope="col" class="p-4 py-3">Description</th>
              <th scope="col" class="p-4 py-3">Account</th>
              <th scope="col" class="p-4 py-3">Category</th>
              <th scope="col" class="p-4 py-3">Date</th>
              <th scope="col" class="p-4 py-3">Amount</th>
            </tr>
          </thead>
          <tbody id="table-body" phx-update="stream">
            <tr :for={{id, transaction} <- @streams.transactions} id={id} class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
              <td class="px-6 py-4"><%= transaction.description %></td>
              <td class="px-6 py-4"><%= transaction.account.name %></td>
              <td class="px-6 py-4"><%= transaction.category.name %></td>
              <td class="px-6 py-4"><%= transaction.date %></td>
              <td class="px-6 py-4"><%= transaction.amount %></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(socket, :transactions, Transactions.list_transactions())
     |> assign(:form, Transactions.change_transaction(%Transaction{}) |> to_form())
     |> assign(:categories, Transactions.list_categories() |> to_options)
     |> assign(:accounts, Accounts.list_accounts() |> to_options)}
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
      {:ok, transaction} ->
        {:noreply,
         socket
         |> stream_insert(:transactions, transaction, at: 0)
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
