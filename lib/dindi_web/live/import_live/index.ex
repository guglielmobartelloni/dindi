defmodule DindiWeb.ImportLive.Index do
    alias Dindi.Countries
    use DindiWeb, :live_view

    alias Ecto.Adapter.Transaction
    alias Dindi.Transactions.Importer

    @impl true
    def render(assigns) do
      ~H"""
      <div class="container-md mx-auto mb-5">
        <div class="card bg-base-300 shadow-xl p-6 mx-auto">
          <.simple_form
            for={@country_form}
            phx-change="country"
            class="mb-5"
          >
            <.input field={@form[:country]} prompt="Country" type="select" options={@countries} />

          </.simple_form>
          <.simple_form
            for={@form}
            phx-submit="connect"
            class="card text-base-content grid lg:grid-cols-6 grid-cols-2 gap-4"
          >
            <input name="account_id" type="hidden" value={@account_id} />
            <.input field={@form[:bank_id]} prompt="Bank" type="select" options={@banks} />

            <.button class="btn-primary">Connect</.button>
          </.simple_form>
        </div>
      </div>
      """
    end

    @impl true
    def mount(%{"id" => id}, _session, socket) do
      {:ok,
       socket
       |> assign(:form, to_form(%{}))
       |> assign(:country_form, to_form(%{}))
       |> assign(:countries, Countries.get_countries)
       |> assign(:account_id, id)
       |> assign(:banks, Importer.new() |> Importer.list_banks() |> to_options)}
    end

    def handle_event("country", %{"country" => country}, socket) do

       socket =
        socket
        |> assign(:banks, Importer.new() |> Importer.list_banks(country) |> to_options)
      {:noreply, socket}

    end


    @impl true
    def handle_event("connect", %{"account_id" => account_id, "bank_id" => bank_id}, socket) do
      %{"id" => id, "link" => link} =
        Importer.new()
        |> Importer.create_link(DindiWeb.Endpoint.url() <> "/import/end", bank_id)

      # To save in the db
      IO.puts(id)
      IO.puts(account_id)

      {:noreply, socket |> redirect(external: link)}
    end

    defp to_options(list) do
      Enum.map(list, fn %{"name" => name, "id" => id} -> {name, id} end)
    end
  end
