defmodule Uni7Web.PageControllerTest do
  use Uni7Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/todos"
  end
end
