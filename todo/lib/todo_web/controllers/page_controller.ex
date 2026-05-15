defmodule TodoWeb.PageController do
  use TodoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
