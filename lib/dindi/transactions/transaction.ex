defmodule Dindi.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :date, :naive_datetime
    field :description, :string
    field :amount, :decimal
    field :category, :id
    field :account, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :date, :amount])
    |> validate_required([:description, :date, :amount])
  end
end
