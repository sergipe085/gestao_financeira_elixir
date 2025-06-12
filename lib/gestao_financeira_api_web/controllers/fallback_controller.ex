# lib/gestao_financeira_api_web/controllers/fallback_controller.ex
defmodule GestaoFinanceiraApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use GestaoFinanceiraApiWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(GestaoFinanceiraApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(GestaoFinanceiraApiWeb.ErrorJSON)
    |> render(:"404")
  end

  # This clause handles authorization errors
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(GestaoFinanceiraApiWeb.ErrorJSON)
    |> render(:"401")
  end

  # This clause handles invalid credentials
  def call(conn, {:error, :invalid_credentials}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Invalid credentials"})
  end

  # Generic error handler
  def call(conn, {:error, reason}) when is_atom(reason) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: to_string(reason)})
  end

  # Handle string errors
  def call(conn, {:error, reason}) when is_binary(reason) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: reason})
  end
end
