defmodule SkimsafeBloggWeb.PageController do
  use SkimsafeBloggWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
