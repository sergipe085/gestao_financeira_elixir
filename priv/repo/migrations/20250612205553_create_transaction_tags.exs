defmodule GestaoFinanceiraApi.Repo.Migrations.CreateTransactionTags do
  use Ecto.Migration

  def change do
    create table(:transaction_tags) do
      add :transaction_id, references(:transactions, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:transaction_tags, [:transaction_id, :tag_id])
  end
end
