defmodule BeamPubWeb.PageController do
  use BeamPubWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
