defmodule DindiWeb.TransactionLive.Index do
  use DindiWeb, :live_view

  alias Dindi.Repo
  alias Dindi.Accounts
  alias Ecto.Adapter.Transaction
  alias Dindi.Transactions.Transaction
  alias Dindi.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container-md mx-auto mb-5">
      <div class="card bg-base-300 shadow-xl p-6 mx-auto">
        <.simple_form
          for={@form}
          phx-change="validate"
          phx-submit="save"
          class="card text-base-content grid lg:grid-cols-6 grid-cols-2 gap-4"
        >
          <.input field={@form[:description]} label="Name" />
          <.input field={@form[:date]} type="date" value={Date.utc_today()} label="Transaction" />

          <.input field={@form[:category_id]} prompt="Category" type="select" options={@categories} />
          <.input field={@form[:account_id]} prompt="Account" type="select" options={@accounts} />

          <.input field={@form[:amount]} type="number" label="Amount" />

          <.button class="btn-primary">Save</.button>
        </.simple_form>
      </div>
    </div>

    <div class="container-md mx-auto">
      <.header>
        <h1 class="text-3xl font-semibold leading-normal">Transactions</h1>
        <:actions>
          <.simple_form
            for={@date_form}
            phx-change="change-date"
            class="card grid grid-cols-2 gap-4 content-evenly mb-3"
          >
            <.input
              field={@date_form[:start]}
              type="date"
              value={Date.beginning_of_month(Date.utc_today())}
            />
            <.input field={@date_form[:end]} type="date" value={Date.end_of_month(Date.utc_today())} />
          </.simple_form>
        </:actions>
      </.header>

      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left text-base-content">
          <thead class="text-xs uppercase bg-base-200">
            <tr class="">
              <th scope="col" class="p-4 py-3">Name</th>
              <th scope="col" class="p-4 py-3">Account</th>
              <th scope="col" class="p-4 py-3">Category</th>
              <th scope="col" class="p-4 py-3">Date</th>
              <th scope="col" class="p-4 py-3">Amount</th>
              <th scope="col" class="p-4 py-3">Action</th>
            </tr>
          </thead>
          <tbody id="table-body" class="bg-base-300" phx-update="stream">
            <tr
              :for={{id, transaction} <- @streams.transactions}
              id={id}
              class="border-b dark:border-gray-700 "
            >
              <td class="px-4 py-4"><%= transaction.description %></td>
              <td class="px-4 py-4"><%= transaction.account.name %></td>
              <td class="px-4 py-4"><%= transaction.category.name %></td>
              <td class="px-4 py-4"><%= transaction.date %></td>
              <td class={[
                "px-4 py-4",
                if(Decimal.compare(transaction.amount, 0) == :gt,
                  do: "text-success",
                  else: "text-error"
                )
              ]}>
                €<%= transaction.amount %>
              </td>
              <td class="px-4 py-4">
                <.link
                  phx-value-id={transaction.id}
                  phx-click="delete-transaction"
                  data-confirm="Are you sure?"
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
                >
                  Delete
                </.link>
              </td>
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
     |> assign(:date_form, to_form(%{"start" => "", "end" => ""}))
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
        IO.inspect(transaction)

        {:noreply,
         socket
         |> stream_insert(:transactions, transaction |> Repo.preload([:category, :account]),
           at: 0
         )
         |> assign(:form, Transactions.change_transaction(%Transaction{}) |> to_form())
         |> put_flash(:info, "Transaction created successfully!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end

  @impl true
  def handle_event("delete-transaction", %{"id" => id}, socket) do
    to_be_deleted_transaction = Transactions.get_transaction!(id)

    case Transactions.delete_transaction(to_be_deleted_transaction) do
      {:ok, transaction} ->
        IO.inspect(transaction)

        {:noreply,
         socket
         |> stream_delete(:transactions, to_be_deleted_transaction)
         |> put_flash(:info, "Transaction deleted successfully!")}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("change-date", %{"start" => start_date, "end" => end_date}, socket) do
    filtered_trans = Transactions.list_transactions_by_date(start_date, end_date)

    socket =
      socket
      |> stream(:transactions, filtered_trans, reset: true)

    {:noreply, socket}
  end

  defp to_options(db_list) do
    Enum.map(db_list, &{&1.name, &1.id})
  end
end
