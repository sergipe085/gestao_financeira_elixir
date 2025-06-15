defmodule GestaoFinanceiraApiWeb.Router do
  use GestaoFinanceiraApiWeb, :router

  import GestaoFinanceiraApiWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GestaoFinanceiraApiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug GestaoFinanceiraApi.Guardian.Pipeline
  end

  scope "/", GestaoFinanceiraApiWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", GestaoFinanceiraApiWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gestao_financeira_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GestaoFinanceiraApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", GestaoFinanceiraApiWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{GestaoFinanceiraApiWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", GestaoFinanceiraApiWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{GestaoFinanceiraApiWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", GestaoFinanceiraApiWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{GestaoFinanceiraApiWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/api", GestaoFinanceiraApiWeb.Api, as: :api do
    pipe_through :api

    # Rotas de autenticação
    post "/users/login", UserController, :login
    post "/users", UserController, :create

    # Rotas protegidas
    pipe_through [Guardian.Plug.EnsureAuthenticated]

    # Users
    resources "/users", UserController, except: [:new, :edit, :create]

    # Transactions
    resources "/transactions", TransactionController, except: [:new, :edit]

    # Tags
    resources "/tags", TagController, except: [:new, :edit]

    # BI Analytics
    scope "/bi" do
      get "/transactions-by-tag", BiController, :transactions_by_tag
      get "/summary-by-tag", BiController, :summary_by_tag
      get "/expense-distribution", BiController, :expense_distribution
    end
  end
end
