defmodule GestaoFinanceiraApi.Finance.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string

    belongs_to :user, GestaoFinanceiraApi.Accounts.User

    many_to_many :transactions, GestaoFinanceiraApi.Finance.Transaction,
      join_through: "transaction_tags"

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
