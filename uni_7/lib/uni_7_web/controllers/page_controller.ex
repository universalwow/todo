defmodule Uni7Web.PageController do
  use Uni7Web, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/todos")
  end
end
