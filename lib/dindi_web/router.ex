defmodule DindiWeb.Router do
  use DindiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DindiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DindiWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", TransactionLive.Index
    # live "/transactions", TransactionLive.Index, :index
    live "/transactions/new", TransactionLive.New
    # live "/transactions/:id/edit", TransactionLive.Index, :edit
    live "/accounts", AccountsLive.Index
    live "/accounts/new", AccountsLive.New
    live "/categories", CategoriesLive.Index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DindiWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dindi, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DindiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
