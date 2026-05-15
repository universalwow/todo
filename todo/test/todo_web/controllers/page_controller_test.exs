defmodule TodoWeb.PageControllerTest do
  use TodoWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Todo"
    assert html_response(conn, 200) =~ "添加一个待办"
  end
end
