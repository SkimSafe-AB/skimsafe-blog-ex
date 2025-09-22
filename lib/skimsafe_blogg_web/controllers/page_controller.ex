defmodule SkimsafeBloggWeb.PageController do
  use SkimsafeBloggWeb, :controller

  alias SkimsafeBlogg.Resources.Post

  def home(conn, _params) do
    # Get featured posts (published and featured)
    {:ok, featured_page} = Post.list_featured()
    featured_posts = featured_page.results

    # Get recent posts (published, ordered by date)
    {:ok, recent_page} = Post.list_recent()
    recent_posts = recent_page.results

    render(conn, :home, featured_posts: featured_posts, recent_posts: recent_posts)
  end
end
