defmodule Dindi.Core do
  alias Dindi.Core.Category
  alias Dindi.Repo
  alias Dindi.Core.Transaction

  def get_transactions() do
    Repo.all(Transaction) |> Repo.preload(:category)
  end

  def get_total_transaction(transactions) do
    total_amount =
      transactions
      |> Enum.map(& &1.amount)
      |> Enum.reduce(Decimal.new(0), fn x, acc -> Decimal.add(x, acc) end)

    %Transaction{title: "TOTAL", amount: total_amount, category: %Category{name: ""}}
  end

  def insert_transaction(params) do
    Transaction.changeset(%Transaction{}, params)
    |> Repo.insert()
  end

  def insert_fake_transaction(_params) do
    Repo.insert(%Transaction{
      title: Faker.Commerce.product_name_product(),
      amount: :rand.uniform() * (1000 - -1000) + -1000,
      category_id: 1
    })
  end
end
