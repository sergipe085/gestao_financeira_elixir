defmodule GestaoFinanceiraApi.FinanceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GestaoFinanceiraApi.Finance` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        date: ~N[2025-06-11 20:53:00],
        description: "some description",
        type: "some type",
        value: "120.5"
      })
      |> GestaoFinanceiraApi.Finance.create_transaction()

    transaction
  end

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> GestaoFinanceiraApi.Finance.create_tag()

    tag
  end
end
