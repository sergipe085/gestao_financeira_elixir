defmodule GestaoFinanceiraApiWeb.Api.TagJSON do
  alias GestaoFinanceiraApi.Finance.Tag

  def index(%{tags: tags}) do
    %{data: for(tag <- tags, do: data(tag))}
  end

  def show(%{tag: tag}) do
    %{data: data(tag)}
  end

  defp data(%Tag{} = tag) do
    %{
      id: tag.id,
      name: tag.name,
      user_id: tag.user_id,
      inserted_at: tag.inserted_at,
      updated_at: tag.updated_at
    }
  end
end
