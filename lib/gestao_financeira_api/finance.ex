defmodule GestaoFinanceiraApi.Finance do
  import Ecto.Query, warn: false
  alias GestaoFinanceiraApi.Repo
  alias GestaoFinanceiraApi.Finance.{Transaction, Tag}

  # Transactions
  def list_transactions(user_id) do
    Transaction
    |> where([t], t.user_id == ^user_id)
    |> preload(:tags)
    |> Repo.all()
  end

  def get_transaction!(id, user_id) do
    Transaction
    |> where([t], t.id == ^id and t.user_id == ^user_id)
    |> preload(:tags)
    |> Repo.one!()
  end

  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  def associate_tags(%Transaction{} = transaction, tag_ids) do
    # First, fetch the transaction with its current tags
    transaction = Repo.preload(transaction, :tags)

    # Get the tags to associate
    _tags = Repo.all(from t in Tag, where: t.id in ^tag_ids)

    # Create a timestamp for all entries
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    # Delete existing associations
    Repo.delete_all(from tt in "transaction_tags", where: tt.transaction_id == ^transaction.id)

    # Insert new associations with timestamps
    tag_ids
    |> Enum.each(fn tag_id ->
      Repo.insert_all(
        "transaction_tags",
        [
          %{
            transaction_id: transaction.id,
            tag_id: tag_id,
            inserted_at: now,
            updated_at: now
          }
        ]
      )
    end)

    # Return the transaction with updated tags
    {:ok, Repo.preload(transaction, :tags, force: true)}
  end

  # Tags
  def list_tags(user_id) do
    Tag
    |> where([t], t.user_id == ^user_id)
    |> Repo.all()
  end

  def get_tag!(id, user_id) do
    Tag
    |> where([t], t.id == ^id and t.user_id == ^user_id)
    |> Repo.one!()
  end

  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  # BI Methods

  @doc """
  Lists transactions grouped by tag for a specific user.
  Returns a list of maps with tag name and associated transactions.
  """
  def list_transactions_by_tag(user_id) do
    query =
      from t in Transaction,
        join: tt in "transaction_tags",
        on: t.id == tt.transaction_id,
        join: tag in Tag,
        on: tt.tag_id == tag.id,
        where: t.user_id == ^user_id,
        preload: [tags: tag]

    transactions = Repo.all(query)

    # Group transactions by tag
    transactions
    |> Enum.flat_map(fn transaction ->
      Enum.map(transaction.tags, fn tag ->
        {tag.name, transaction}
      end)
    end)
    |> Enum.group_by(fn {tag_name, _} -> tag_name end, fn {_, transaction} -> transaction end)
  end

  @doc """
  Summarizes income and expenses by tag for a specific user.
  Returns a list of maps with tag name, total income and total expenses.
  """
  def summarize_by_tag(user_id) do
    query =
      from t in Transaction,
        join: tt in "transaction_tags",
        on: t.id == tt.transaction_id,
        join: tag in Tag,
        on: tt.tag_id == tag.id,
        where: t.user_id == ^user_id,
        group_by: [tag.id, tag.name, t.type],
        select: {tag.id, tag.name, t.type, sum(t.value)}

    result = Repo.all(query)

    # Transform the result into a more usable format
    result
    |> Enum.group_by(fn {tag_id, tag_name, _, _} -> {tag_id, tag_name} end, fn {_, _, type, sum} ->
      {type, sum}
    end)
    |> Enum.map(fn {{tag_id, tag_name}, values} ->
      income =
        Enum.find_value(values, Decimal.new(0), fn
          {:receita, sum} -> sum
          _ -> nil
        end)

      expense =
        Enum.find_value(values, Decimal.new(0), fn
          {:despesa, sum} -> sum
          _ -> nil
        end)

      %{
        tag_id: tag_id,
        tag_name: tag_name,
        income: income,
        expense: expense,
        balance: Decimal.sub(income, expense)
      }
    end)
  end

  @doc """
  Gets monthly summary of transactions grouped by type (income/expense).
  Returns a list of maps with month, year, total income and total expenses.
  """
  def monthly_summary(user_id, year) do
    query =
      from t in Transaction,
        where: t.user_id == ^user_id and fragment("EXTRACT(YEAR FROM ?)", t.date) == ^year,
        group_by: [fragment("EXTRACT(MONTH FROM ?)", t.date), t.type],
        select: {
          fragment("EXTRACT(MONTH FROM ?)", t.date),
          t.type,
          sum(t.value)
        },
        order_by: fragment("EXTRACT(MONTH FROM ?)", t.date)

    result = Repo.all(query)

    # Transform the result into a more usable format grouped by month
    result
    |> Enum.group_by(fn {month, _, _} -> month end, fn {_, type, sum} -> {type, sum} end)
    |> Enum.map(fn {month, values} ->
      income =
        Enum.find_value(values, Decimal.new(0), fn
          {:receita, sum} -> sum
          _ -> nil
        end)

      expense =
        Enum.find_value(values, Decimal.new(0), fn
          {:despesa, sum} -> sum
          _ -> nil
        end)

      %{
        month: trunc(month),
        year: year,
        income: income,
        expense: expense,
        balance: Decimal.sub(income, expense)
      }
    end)
    |> Enum.sort_by(fn %{month: month} -> month end)
  end

  @doc """
  Gets transactions for a specific tag.
  """
  def transactions_by_tag_id(user_id, tag_id) do
    query =
      from t in Transaction,
        join: tt in "transaction_tags",
        on: t.id == tt.transaction_id,
        where: t.user_id == ^user_id and tt.tag_id == ^tag_id,
        preload: [:tags]

    Repo.all(query)
  end

  @doc """
  Gets distribution of expenses by tag for a specific period.
  """
  def expense_distribution_by_tag(user_id, start_date, end_date) do
    query =
      from t in Transaction,
        join: tt in "transaction_tags",
        on: t.id == tt.transaction_id,
        join: tag in Tag,
        on: tt.tag_id == tag.id,
        where:
          t.user_id == ^user_id and t.type == :despesa and t.date >= ^start_date and
            t.date <= ^end_date,
        group_by: [tag.id, tag.name],
        select: {tag.id, tag.name, sum(t.value)}

    Repo.all(query)
    |> Enum.map(fn {id, name, sum} -> %{tag_id: id, tag_name: name, total: sum} end)
    |> Enum.sort_by(fn %{total: total} -> Decimal.to_float(total) end, :desc)
  end
end
