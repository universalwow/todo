defmodule Uni7Web.PageController do
  use Uni7Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
