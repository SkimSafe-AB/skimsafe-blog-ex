defmodule SkimsafeBlogg.Blog.PostUpdater do
  alias SkimsafeBlogg.Resources.Post
  alias SkimsafeBlogg.Repo

  def get_posts_without_read_time do
    {:ok, page} = Post.list_all_posts()

    page.results
    |> Enum.filter(fn post ->
      is_nil(post.read_time_minutes) or post.read_time_minutes == 0
    end)
  end

  def get_posts_by_ids(post_ids) do
    {:ok, page} = Post.list_all_posts()

    page.results
    |> Enum.filter(fn post ->
      Enum.any?(post_ids, &(&1 == to_string(post.id) or &1 == post.slug))
    end)
  end

  def update_post_read_time(post_id, minutes) do
    # Direct SQLite update since we're working with existing records
    query = "UPDATE posts SET read_time_minutes = ? WHERE id = ?"
    Ecto.Adapters.SQL.query!(Repo, query, [minutes, post_id])
  end
end
