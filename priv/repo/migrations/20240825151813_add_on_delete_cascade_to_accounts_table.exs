defmodule Dindi.Repo.Migrations.AddOnDeleteCascadeToAccountsTable do
  use Ecto.Migration

 def change do
    alter table(:transactions) do
      modify :account_id, references(:accounts, on_delete: :delete_all)
    end
  end

end
