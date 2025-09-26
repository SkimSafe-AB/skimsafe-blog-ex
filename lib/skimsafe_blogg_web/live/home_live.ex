defmodule SkimsafeBloggWeb.HomeLive do
  use SkimsafeBloggWeb, :live_view

  alias SkimsafeBlogg.Resources.Post

  def mount(_params, _session, socket) do
    # Get featured posts (published and featured)
    {:ok, featured_page} = Post.list_featured()
    featured_posts = featured_page.results

    # Get recent posts (published, ordered by date)
    {:ok, recent_page} = Post.list_recent()
    recent_posts = recent_page.results

    # Get all posts for the "View All" section (first 6)
    {:ok, all_posts_page} = Post.list_all_posts()
    all_posts = all_posts_page.results
    has_more_posts = all_posts_page.more?

    socket =
      socket
      |> assign(:featured_posts, featured_posts)
      |> assign(:recent_posts, recent_posts)
      |> assign(:all_posts, all_posts)
      |> assign(:has_more_posts, has_more_posts)
      |> assign(:page_offset, 0)
      |> assign(:loading_more, false)

    {:ok, socket}
  end

  def handle_event("load_more", _params, socket) do
    new_offset = socket.assigns.page_offset + 6

    # Get next batch of posts using Ash pagination
    {:ok, more_posts_page} = Post.list_all_posts(page: [offset: new_offset, limit: 6])
    new_posts = more_posts_page.results

    socket =
      socket
      |> assign(:all_posts, socket.assigns.all_posts ++ new_posts)
      |> assign(:has_more_posts, more_posts_page.more?)
      |> assign(:page_offset, new_offset)
      |> assign(:loading_more, false)

    {:noreply, socket}
  end

  def handle_event("loading_more", _params, socket) do
    {:noreply, assign(socket, :loading_more, true)}
  end

  def handle_event("show_less", _params, socket) do
    # Get the first 6 posts again
    {:ok, all_posts_page} = Post.list_all_posts()
    first_six_posts = all_posts_page.results

    socket =
      socket
      |> assign(:all_posts, first_six_posts)
      |> assign(:has_more_posts, all_posts_page.more?)
      |> assign(:page_offset, 0)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-gray-900">
      <Layouts.flash_group flash={@flash} />
      
    <!-- Hero Section -->
      <div class="bg-white dark:bg-gray-900 py-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center">
            <h1 class="text-4xl font-bold sm:text-5xl lg:text-6xl mb-6 hero-shimmer">
              Developer Blog
            </h1>
            <p class="text-xl text-gray-600 max-w-3xl mx-auto dark:text-gray-300">
              Exploring Elixir, Phoenix, and modern web development through practical insights and tutorials.
            </p>
          </div>
        </div>
      </div>
      
    <!-- Main Content -->
      <div class="max-w-7xl mx-auto px-4 py-12 sm:px-6 lg:px-8">
        <!-- Featured Post Section -->
        <div class="mb-12">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 dark:text-white">Featured Post</h2>
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <.featured_blog_card
              :for={post <- @featured_posts}
              title={post.title}
              excerpt={post.excerpt}
              author={post.author}
              published_at={post.published_date_string}
              read_time={post.read_time}
              tags={post.tags}
              href={post.href}
            />
          </div>
        </div>
        
    <!-- Recent Posts Section -->
        <div class="mb-12">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 dark:text-white">Recent Posts</h2>
          <.blog_grid posts={@recent_posts} />
        </div>
        
    <!-- All Posts Section -->
        <div class="mb-12">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 dark:text-white">All Posts</h2>
          <.blog_grid posts={@all_posts} />
          
    <!-- Load More / Show Less Buttons -->
          <div class="text-center mt-8 space-y-4">
            <!-- Load More Button -->
            <div :if={@has_more_posts}>
              <button
                phx-click="load_more"
                phx-click-loading="loading_more"
                disabled={@loading_more}
                class={[
                  "inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md",
                  "bg-purple-600 text-white hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500",
                  "disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200",
                  "dark:focus:ring-offset-gray-900"
                ]}
              >
                <span :if={!@loading_more}>Load More Posts</span>
                <span :if={@loading_more} class="flex items-center">
                  <svg
                    class="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      class="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      stroke-width="4"
                    >
                    </circle>
                    <path
                      class="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    >
                    </path>
                  </svg>
                  Loading...
                </span>
              </button>
            </div>
            
    <!-- Show Less Button -->
            <div :if={@page_offset > 0}>
              <button
                phx-click="show_less"
                class={[
                  "inline-flex items-center px-6 py-3 border border-gray-300 dark:border-gray-600 text-base font-medium rounded-md",
                  "bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700",
                  "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 transition-colors duration-200",
                  "dark:focus:ring-offset-gray-900"
                ]}
              >
                <.icon name="hero-chevron-up" class="w-4 h-4 mr-2" /> Show Less
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
