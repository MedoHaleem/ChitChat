defmodule ChitChatWeb.SessionController do
  use ChitChatWeb, :controller

  alias ChitChat.Accounts

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.authenticate_by_email_password(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, :unauthroized} ->
        conn
        |> put_flash(:error, "Bad email or password!")
        |> redirect(to: Routes.session_path(conn, :new))

        {:error, :not_found} ->
          conn
          |> put_flash(:error, "Account not found")
          |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:success, "Successfuly signed out")
    |> redirect(to: "/")
  end
end
