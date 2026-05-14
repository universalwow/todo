defmodule Uni7Web.ErrorJSONTest do
  use Uni7Web.ConnCase, async: true

  test "renders 404" do
    assert Uni7Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Uni7Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
