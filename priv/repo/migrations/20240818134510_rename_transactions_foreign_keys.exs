defmodule Dindi.Repo.Migrations.RenameTransactionsForeignKeys do
  use Ecto.Migration

  def change do
    rename table("transactions"), :category, to: :category_id
    rename table("transactions"), :account, to: :account_id
  end
end
