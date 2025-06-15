defmodule GestaoFinanceiraApiWeb.Api.BiController do
  use GestaoFinanceiraApiWeb, :controller

  alias GestaoFinanceiraApi.Finance
  alias GestaoFinanceiraApi.Guardian

  action_fallback GestaoFinanceiraApiWeb.FallbackController

  plug Guardian.Pipeline

  def transactions_by_tag(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    transactions_by_tag = Finance.list_transactions_by_tag(current_user.id)
    render(conn, :transactions_by_tag, transactions_by_tag: transactions_by_tag)
  end

  def summary_by_tag(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    summary = Finance.summarize_by_tag(current_user.id)
    render(conn, :summary_by_tag, summary: summary)
  end

  def expense_distribution(conn, %{"start_date" => start_date, "end_date" => end_date}) do
    current_user = Guardian.Plug.current_resource(conn)

    {:ok, start_date} = NaiveDateTime.from_iso8601("#{start_date}T00:00:00")
    {:ok, end_date} = NaiveDateTime.from_iso8601("#{end_date}T23:59:59")

    distribution = Finance.expense_distribution_by_tag(current_user.id, start_date, end_date)
    render(conn, :expense_distribution, distribution: distribution)
  end
end
