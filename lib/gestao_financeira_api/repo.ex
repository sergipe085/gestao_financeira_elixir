defmodule GestaoFinanceiraApi.Repo do
  use Ecto.Repo,
    otp_app: :gestao_financeira_api,
    adapter: Ecto.Adapters.Postgres
end
