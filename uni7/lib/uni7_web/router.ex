defmodule Uni7Web.Router do
  use Uni7Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Uni7Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Uni7Web do
    pipe_through :browser

    get "/", PageController, :home

    live "/todos", TodoItemLive.Index, :index
    live "/todos/new", TodoItemLive.Form, :new
    live "/todos/:id", TodoItemLive.Show, :show
    live "/todos/:id/edit", TodoItemLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", Uni7Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:uni7, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Uni7Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
