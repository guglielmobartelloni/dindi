defmodule Dindi.Accounts.Account do
  alias Dindi.Transactions.Transaction
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    field :initial_amount, :decimal
    field :total_amount, :decimal, virtual: true, default: 0

    has_many :transactions, Transaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :initial_amount])
    |> validate_required([:name])
  end

  def populate_total_amount(
        %Dindi.Accounts.Account{initial_amount: initial_amount, transactions: transactions} =
          account
      ) do
    %{account | total_amount: calculate_total_amount(initial_amount, transactions)}
  end

  defp calculate_total_amount(initial_amount, transactions) do
    Decimal.add(
      initial_amount,
      Enum.reduce(transactions, 0, fn trans, acc -> Decimal.add(trans.amount, acc) end)
    )
  end
end
