defmodule Dindi.Core do
  alias Dindi.Repo
  alias Dindi.Core.Transaction

  def get_transactions() do
    Repo.all(Transaction) |> Repo.preload(:category)
  end

  def insert_transaction(params) do
    Transaction.changeset(%Transaction{}, params)
    |> Repo.insert()
  end
end
