defmodule Dindi.Repo.Migrations.DropPreviousTransactionsConstraint do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE transactions DROP CONSTRAINT transactions_account_fkey"
  end
end
