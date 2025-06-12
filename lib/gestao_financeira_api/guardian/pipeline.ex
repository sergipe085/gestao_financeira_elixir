defmodule GestaoFinanceiraApi.Guardian.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :gestao_financeira_api,
    module: GestaoFinanceiraApi.Guardian,
    error_handler: GestaoFinanceiraApi.Guardian.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end
