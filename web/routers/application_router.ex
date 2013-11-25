defmodule ApplicationRouter do
  use Dynamo.Router

  import HangGameEngine
  
  prepare do
    # Pick which parts of the request you want to fetch
    # You can comment the line below if you don't need
    # any of them or move them to a forwarded router
    conn.fetch([:cookies, :params, :session])
  end

  # It is common to break your Dynamo into many
  # routers, forwarding the requests between them:
  # forward "/posts", to: PostsRouter

  get "/" do
    {conn, secret, tries} = state(conn)
    partial_guess = partial_guess(secret, tries)
    incorrect_attempts = incorrect_attempts(secret, tries)
    conn = conn.assign(:secret, secret)
    conn = conn.assign(:partial_guess, partial_guess)
    conn = conn.assign(:won, guessed?(secret, tries))
    conn = conn.assign(:lost, incorrect_attempts > 8)
    conn = conn.assign(:incorrect_attempts, incorrect_attempts)
    conn = conn.assign(:attempts_list, ordered_uniqueue_list(tries))
    render conn, "index.html"
  end

  post "/" do
    letter = Dict.get(conn.params, :letter)
    if letter =~ %r/^[a-z]$/i do
      {conn, secret, tries} = state(conn)
      {:ok, char} = letter |> String.downcase |> String.to_char_list
      conn = state_update(conn, secret, char ++ tries)
    end
    
    redirect(conn, to: "/")
  end

  get "/new" do
    delete_session(conn, :state) |> redirect(to: "/")
  end

  get "/hint" do
    {conn, secret, _tries} = state(conn)
    url = secret |> list_to_bitstring |> search_giphy
    if nil?(url) do
      conn.send(400, "")
    else
      conn.send(200, url)
    end
  end

  defp state(conn) do
    state = get_session(conn, :state)
    if nil?(state) do
      secret = Secrets.options |> random_element |> bitstring_to_list
      tries = []
      conn = state_update(conn, secret, tries)
    else
      {secret, tries} = state
    end
    {conn, secret, tries}
  end

  defp state_update(conn, secret, tries) do
    put_session(conn, :state, {secret, tries})
  end
end
