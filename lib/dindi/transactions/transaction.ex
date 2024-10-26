defmodule Dindi.Transactions.Transaction do
  alias Dindi.Accounts.Account
  alias Dindi.Transactions.Category
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :date, :date
    field :description, :string
    field :amount, :decimal
    field :unique_id, :string
    belongs_to :category, Category
    belongs_to :account, Account

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :date, :amount, :category_id, :account_id])
    # |> cast_assoc(:category)
    # |> cast_assoc(:account)
    |> validate_required([:description, :date, :amount, :category_id, :account_id])
  end

end
