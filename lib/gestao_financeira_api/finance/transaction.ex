defmodule GestaoFinanceiraApi.Finance.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :description, :string
    field :value, :decimal
    field :type, Ecto.Enum, values: [:receita, :despesa]
    field :date, :naive_datetime

    belongs_to :user, MyApp.Accounts.User
    many_to_many :tags, MyApp.Finance.Tag, join_through: "transaction_tags"

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:description, :value, :type, :date, :user_id])
    |> validate_required([:description, :value, :type, :date, :user_id])
    |> validate_number(:value, greater_than: 0)
    |> foreign_key_constraint(:user_id)
  end
end
