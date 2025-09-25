defmodule SkimsafeBloggWeb.PostLive do
  use SkimsafeBloggWeb, :live_view

  alias SkimsafeBlogg.Resources.Post
  alias SkimsafeBlogg.Blog.PostRenderer

  def mount(%{"slug" => slug}, _session, socket) do
    case Post.get_by_slug(slug) do
      {:ok, post} ->
        # Render the markdown content to HTML with syntax highlighting
        processed_post = PostRenderer.process_post(post)
        {:ok, assign(socket, post: processed_post, page_title: post.title)}

      {:error, _} ->
        {:ok, socket |> put_flash(:error, "Post not found") |> redirect(to: "/")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-gray-900">
      <div class="max-w-4xl mx-auto px-4 py-8 pt-16">
        <article class="bg-white dark:bg-gray-900">
          <!-- Header -->
          <header class="mb-8 border-b border-gray-200 dark:border-gray-700 pb-8">
            <h1 class="text-4xl font-bold mb-4 text-gray-900 dark:text-white leading-tight">
              {@post.title}
            </h1>
            
    <!-- Meta information -->
            <div class="flex flex-wrap items-center gap-4 text-gray-600 dark:text-gray-400 mb-6">
              <span class="font-medium text-purple-600 dark:text-purple-400">
                {@post.author}
              </span>
              <span>•</span>
              <time>{@post.published_date_string}</time>
              <span>•</span>
              <span>{@post.read_time}</span>
            </div>
            
    <!-- Tags -->
            <div :if={@post.tags != []} class="flex flex-wrap gap-2">
              <span
                :for={tag <- Enum.take(@post.tags, 5)}
                class="px-3 py-1 bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200 rounded-full text-sm font-medium hover:bg-purple-200 dark:hover:bg-purple-800 transition-colors"
              >
                {tag}
              </span>
            </div>
          </header>
          
    <!-- Article content with syntax highlighting -->
          <div class="blog-content prose prose-lg max-w-none">
            {raw(@post.rendered_content)}
          </div>
          
    <!-- Footer -->
          <footer class="mt-12 pt-8 border-t border-gray-200 dark:border-gray-700">
            <div class="flex items-center justify-between">
              <div class="text-sm text-gray-500 dark:text-gray-400">
                Published on {@post.published_date_string}
              </div>
              <div class="flex items-center space-x-4">
                <.link
                  navigate="/"
                  class="text-purple-600 hover:text-purple-700 dark:text-purple-400 dark:hover:text-purple-300 font-medium"
                >
                  ← Back to Blog
                </.link>
              </div>
            </div>
          </footer>
        </article>
      </div>
    </div>
    """
  end
end
