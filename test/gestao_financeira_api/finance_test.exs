defmodule GestaoFinanceiraApi.FinanceTest do
  use GestaoFinanceiraApi.DataCase

  alias GestaoFinanceiraApi.Finance

  describe "transactions" do
    alias GestaoFinanceiraApi.Finance.Transaction

    import GestaoFinanceiraApi.FinanceFixtures

    @invalid_attrs %{type: nil, value: nil, date: nil, description: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Finance.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Finance.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{type: "some type", value: "120.5", date: ~N[2025-06-11 20:53:00], description: "some description"}

      assert {:ok, %Transaction{} = transaction} = Finance.create_transaction(valid_attrs)
      assert transaction.type == "some type"
      assert transaction.value == Decimal.new("120.5")
      assert transaction.date == ~N[2025-06-11 20:53:00]
      assert transaction.description == "some description"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finance.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      update_attrs = %{type: "some updated type", value: "456.7", date: ~N[2025-06-12 20:53:00], description: "some updated description"}

      assert {:ok, %Transaction{} = transaction} = Finance.update_transaction(transaction, update_attrs)
      assert transaction.type == "some updated type"
      assert transaction.value == Decimal.new("456.7")
      assert transaction.date == ~N[2025-06-12 20:53:00]
      assert transaction.description == "some updated description"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Finance.update_transaction(transaction, @invalid_attrs)
      assert transaction == Finance.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Finance.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Finance.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Finance.change_transaction(transaction)
    end
  end

  describe "tags" do
    alias GestaoFinanceiraApi.Finance.Tag

    import GestaoFinanceiraApi.FinanceFixtures

    @invalid_attrs %{name: nil}

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Finance.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Finance.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Tag{} = tag} = Finance.create_tag(valid_attrs)
      assert tag.name == "some name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finance.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Tag{} = tag} = Finance.update_tag(tag, update_attrs)
      assert tag.name == "some updated name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Finance.update_tag(tag, @invalid_attrs)
      assert tag == Finance.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Finance.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Finance.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Finance.change_tag(tag)
    end
  end
end
