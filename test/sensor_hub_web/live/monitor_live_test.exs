defmodule SensorHubWeb.MonitorLiveTest do
  use SensorHubWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Monitor"
    assert render(page_live) =~ "Monitor"
  end
end
