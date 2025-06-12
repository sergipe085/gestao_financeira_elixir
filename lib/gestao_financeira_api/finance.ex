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
    tags = Repo.all(from t in Tag, where: t.id in ^tag_ids)

    transaction
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update()
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
end
