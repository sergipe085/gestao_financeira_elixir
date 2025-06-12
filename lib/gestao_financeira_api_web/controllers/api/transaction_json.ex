defmodule GestaoFinanceiraApiWeb.Api.TransactionJSON do
  alias GestaoFinanceiraApi.Finance.Transaction

  def index(%{transactions: transactions}) do
    %{data: for(transaction <- transactions, do: data(transaction))}
  end

  def show(%{transaction: transaction}) do
    %{data: data(transaction)}
  end

  defp data(%Transaction{} = transaction) do
    %{
      id: transaction.id,
      description: transaction.description,
      value: transaction.value,
      type: transaction.type,
      date: transaction.date,
      user_id: transaction.user_id,
      tags:
        if(Ecto.assoc_loaded?(transaction.tags),
          do: Enum.map(transaction.tags, &tag_data/1),
          else: []
        ),
      inserted_at: transaction.inserted_at,
      updated_at: transaction.updated_at
    }
  end

  defp tag_data(tag) do
    %{
      id: tag.id,
      name: tag.name
    }
  end
end
