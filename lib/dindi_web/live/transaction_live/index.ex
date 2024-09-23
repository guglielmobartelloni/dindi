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
    <.button class="btn-primary" phx-click={show_modal("form-modal")}>Create transaction</.button>
    <.modal id="form-modal">
      <div class="container mx-auto p-4">
        <div class="card">
          <.simple_form for={@form} phx-change="validate" phx-submit="save" class="card-body mx-auto">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <.input field={@form[:description]} label="Name" prompt="Amazon superman pants" />
              <.input field={@form[:date]} type="date" value={Date.utc_today()} label="Transaction" />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <.input field={@form[:type]} label="Type" type="select" options={@types} />
              <.input
                field={@form[:category_id]}
                type="select"
                label="Category"
                options={@categories}
              />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <.input field={@form[:account_id]} label="Account" type="select" options={@accounts} />
              <.input field={@form[:amount]} type="number" label="Amount" />
            </div>

            <.button class="btn-primary mt-5" phx-click={hide_modal("form-modal")}>Save</.button>
          </.simple_form>
        </div>
      </div>
    </.modal>

    <div class="container-md mx-auto mb-5">
      <.header class="mb-3">
        <div class="grid grid-cols-2 gap-2">
          <h1 class="text-3xl text-base-content font-semibold leading-normal">Transactions</h1>
          <.link
            phx-click="reset-date"
            class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
          >
            Reset
          </.link>
        </div>
        <:actions>
          <.simple_form
            for={@date_form}
            phx-change="change-date"
            class="card grid grid-cols-2 gap-4 content-evenly"
          >
            <.input field={@date_form[:start]} type="date" />
            <.input field={@date_form[:end]} type="date" />
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
              class="border-b border-base-100 "
            >
              <td class="px-4 py-4"><%= transaction.description %></td>
              <%= if transaction.account != nil do %>
                <td class="px-4 py-4"><%= transaction.account.name %></td>
              <% else %>
                <td class="px-4 py-4"></td>
              <% end %>
              <%= if transaction.account != nil do %>
                <td class="px-4 py-4"><%= transaction.category.name %></td>
              <% else %>
                <td class="px-4 py-4"></td>
              <% end %>
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
                  class="font-medium text-red-600 dark:text-red-500 hover:underline"
                >
                  Delete
                </.link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="max-w-sm w-full bg-white rounded-lg shadow dark:bg-gray-800 p-4 md:p-6">
      <div class="flex justify-between">
        <div>
          <h5 class="leading-none text-3xl font-bold text-gray-900 dark:text-white pb-2">32.4k</h5>
          <p class="text-base font-normal text-gray-500 dark:text-gray-400">Users this week</p>
        </div>
        <div class="flex items-center px-2.5 py-0.5 text-base font-semibold text-green-500 dark:text-green-500 text-center">
          12%
          <svg
            class="w-3 h-3 ms-1"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 10 14"
          >
            <path
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 13V1m0 0L1 5m4-4 4 4"
            />
          </svg>
        </div>
      </div>
      <div id="area-chart"></div>
      <div class="grid grid-cols-1 items-center border-gray-200 border-t dark:border-gray-700 justify-between">
        <div class="flex justify-between items-center pt-5">
          <!-- Button -->
          <button
            id="dropdownDefaultButton"
            data-dropdown-toggle="lastDaysdropdown"
            data-dropdown-placement="bottom"
            class="text-sm font-medium text-gray-500 dark:text-gray-400 hover:text-gray-900 text-center inline-flex items-center dark:hover:text-white"
            type="button"
          >
            Last 7 days
            <svg
              class="w-2.5 m-2.5 ms-1.5"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 10 6"
            >
              <path
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="m1 1 4 4 4-4"
              />
            </svg>
          </button>
          <!-- Dropdown menu -->
          <div
            id="lastDaysdropdown"
            class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
          >
            <ul
              class="py-2 text-sm text-gray-700 dark:text-gray-200"
              aria-labelledby="dropdownDefaultButton"
            >
              <li>
                <a
                  href="#"
                  class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                >
                  Yesterday
                </a>
              </li>
              <li>
                <a
                  href="#"
                  class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                >
                  Today
                </a>
              </li>
              <li>
                <a
                  href="#"
                  class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                >
                  Last 7 days
                </a>
              </li>
              <li>
                <a
                  href="#"
                  class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                >
                  Last 30 days
                </a>
              </li>
              <li>
                <a
                  href="#"
                  class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
                >
                  Last 90 days
                </a>
              </li>
            </ul>
          </div>
          <a
            href="#"
            class="uppercase text-sm font-semibold inline-flex items-center rounded-lg text-blue-600 hover:text-blue-700 dark:hover:text-blue-500  hover:bg-gray-100 dark:hover:bg-gray-700 dark:focus:ring-gray-700 dark:border-gray-700 px-3 py-2"
          >
            Users Report
            <svg
              class="w-2.5 h-2.5 ms-1.5 rtl:rotate-180"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 6 10"
            >
              <path
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="m1 9 4-4-4-4"
              />
            </svg>
          </a>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(socket, :transactions, Transactions.list_transactions())
     |> assign(:form, Transactions.change_transaction(%Transaction{}) |> to_form())
     |> assign(
       :date_form,
       to_form(%{
         "start" => Date.beginning_of_month(Date.utc_today()),
         "end" => Date.end_of_month(Date.utc_today())
       })
     )
     |> assign(:types, [{"+", :gain}, {"-", :expense}])
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
    transaction_params =
      case transaction_params do
        %{"type" => "gain"} ->
          transaction_params

        %{"type" => "expense", "amount" => amount} ->
          %{transaction_params | "amount" => Decimal.mult(amount, -1)}
      end
      |> trim()

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
      |> put_flash(:info, "Filtered transactions")

    {:noreply, socket}
  end

  @impl true
  def handle_event("reset-date", _, socket) do
    socket =
      socket
      |> stream(:transactions, Transactions.list_transactions(), reset: true)
      |> assign(:date_form, to_form(%{"start" => "", "end" => ""}))

    {:noreply, socket}
  end

  defp to_options(list) do
    Enum.map(list, &{&1.name, &1.id})
  end

  defp trim(%{"description" => desc} = params) do
    %{params | "description" => desc |> String.trim()}
  end
end
