defmodule ChitChat.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias ChitChatWeb.Router.Helpers, as: Routes
  alias ChitChatWeb.ErrorView

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && ChitChat.Accounts.get_user!(user_id)
    put_current_user(conn, user)
  end

  def logged_in_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end


  def admin_user(conn = %{assigns: %{admin_user: true}}, _), do: conn
  def admin_user(conn, opts) do
    if opts[:pokerface] do
      conn |> put_status(404) |> render(ErrorView, :"404", message: "Page not found") |> halt()
    end

    conn |> put_flash(:error, "You don't have access to that page") |> redirect(to: Routes.page_path(conn, :index)) |> halt()
  end

  def put_current_user(conn, user) do
    token = user && Phoenix.Token.sign(conn, "user socket", user.id)
    conn
    |> assign(:current_user, user)
    |> assign(:admin_user, !!user && !!user.credential && user.credential.email == "test@test.com")
    |> assign(:user_token, token)
  end
end
