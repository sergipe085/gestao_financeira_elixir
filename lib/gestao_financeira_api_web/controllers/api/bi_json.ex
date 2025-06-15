defmodule GestaoFinanceiraApiWeb.Api.BiJSON do
  alias GestaoFinanceiraApi.Finance.Transaction

  @doc """
  Renders transactions grouped by tag
  """
  def transactions_by_tag(%{transactions_by_tag: transactions_by_tag}) do
    %{
      data: Enum.map(transactions_by_tag, fn {tag_name, transactions} ->
        %{
          tag: tag_name,
          transactions: Enum.map(transactions, &transaction_json/1)
        }
      end)
    }
  end

  @doc """
  Renders summary by tag
  """
  def summary_by_tag(%{summary: summary}) do
    %{
      data: Enum.map(summary, fn item ->
        %{
          tag_id: item.tag_id,
          tag_name: item.tag_name,
          income: item.income,
          expense: item.expense,
          balance: item.balance
        }
      end)
    }
  end

  @doc """
  Renders monthly summary
  """
  def monthly_summary(%{summary: summary}) do
    %{
      data: Enum.map(summary, fn item ->
        %{
          month: item.month,
          year: item.year,
          income: item.income,
          expense: item.expense,
          balance: item.balance
        }
      end)
    }
  end

  @doc """
  Renders transactions for a specific tag
  """
  def transactions(%{transactions: transactions}) do
    %{data: Enum.map(transactions, &transaction_json/1)}
  end

  @doc """
  Renders expense distribution by tag
  """
  def expense_distribution(%{distribution: distribution}) do
    %{
      data: Enum.map(distribution, fn item ->
        %{
          tag_id: item.tag_id,
          tag_name: item.tag_name,
          total: item.total
        }
      end)
    }
  end

  defp transaction_json(%Transaction{} = transaction) do
    %{
      id: transaction.id,
      description: transaction.description,
      value: transaction.value,
      type: transaction.type,
      date: transaction.date,
      tags: Enum.map(transaction.tags, fn tag -> %{id: tag.id, name: tag.name} end)
    }
  end
end
