defmodule GestaoFinanceiraApiWeb.Api.TransactionController do
  use GestaoFinanceiraApiWeb, :controller

  alias GestaoFinanceiraApi.Finance
  alias GestaoFinanceiraApi.Finance.Transaction
  alias GestaoFinanceiraApi.Guardian

  action_fallback GestaoFinanceiraApiWeb.FallbackController

  plug Guardian.Pipeline

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    transactions = Finance.list_transactions(current_user.id)
    render(conn, :index, transactions: transactions)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    transaction_params = Map.put(transaction_params, "user_id", current_user.id)

    with {:ok, %Transaction{} = transaction} <- Finance.create_transaction(transaction_params) do
      # Associar tags se fornecidas
      transaction = if tag_ids = transaction_params["tag_ids"] do
        case Finance.associate_tags(transaction, tag_ids) do
          {:ok, updated_transaction} -> updated_transaction
          _ -> transaction
        end
      else
        transaction
      end

      conn
      |> put_status(:created)
      |> render(:show, transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    transaction = Finance.get_transaction!(id, current_user.id)
    render(conn, :show, transaction: transaction)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    transaction = Finance.get_transaction!(id, current_user.id)

    with {:ok, %Transaction{} = transaction} <-
           Finance.update_transaction(transaction, transaction_params) do
      # Atualizar tags se fornecidas
      transaction = if tag_ids = transaction_params["tag_ids"] do
        case Finance.associate_tags(transaction, tag_ids) do
          {:ok, updated_transaction} -> updated_transaction
          _ -> transaction
        end
      else
        transaction
      end

      render(conn, :show, transaction: transaction)
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    transaction = Finance.get_transaction!(id, current_user.id)

    with {:ok, %Transaction{}} <- Finance.delete_transaction(transaction) do
      send_resp(conn, :no_content, "")
    end
  end
end
