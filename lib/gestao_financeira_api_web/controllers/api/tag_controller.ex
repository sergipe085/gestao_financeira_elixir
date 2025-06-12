defmodule GestaoFinanceiraApiWeb.Api.TagController do
  use GestaoFinanceiraApiWeb, :controller

  alias GestaoFinanceiraApi.Finance
  alias GestaoFinanceiraApi.Finance.Tag
  alias GestaoFinanceiraApi.Guardian

  action_fallback GestaoFinanceiraApiWeb.FallbackController

  plug Guardian.Pipeline

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    tags = Finance.list_tags(current_user.id)
    render(conn, :index, tags: tags)
  end

  def create(conn, %{"tag" => tag_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    tag_params = Map.put(tag_params, "user_id", current_user.id)

    with {:ok, %Tag{} = tag} <- Finance.create_tag(tag_params) do
      conn
      |> put_status(:created)
      |> render(:show, tag: tag)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    tag = Finance.get_tag!(id, current_user.id)
    render(conn, :show, tag: tag)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    tag = Finance.get_tag!(id, current_user.id)

    with {:ok, %Tag{} = tag} <- Finance.update_tag(tag, tag_params) do
      render(conn, :show, tag: tag)
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    tag = Finance.get_tag!(id, current_user.id)

    with {:ok, %Tag{}} <- Finance.delete_tag(tag) do
      send_resp(conn, :no_content, "")
    end
  end
end
