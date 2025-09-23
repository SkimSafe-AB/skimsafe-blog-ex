defmodule SkimsafeBlogg.Resources.Post do
  @moduledoc """
  Post resource for blog posts stored in SQLite database.
  This resource is read-only and only supports fetching posts.
  """
  use Ash.Resource,
    otp_app: :skimsafe_blogg,
    domain: SkimsafeBlogg.Domain,
    data_layer: AshSqlite.DataLayer

  sqlite do
    repo(SkimsafeBlogg.Repo)
    table "posts"
  end

  # Code interface for easier usage in LiveViews and controllers
  code_interface do
    domain SkimsafeBlogg.Domain
    define :list_published, action: :published
    define :list_featured, action: :featured
    define :list_recent, action: :recent
    define :list_all_posts, action: :all_posts
    define :get_by_slug, action: :by_slug, args: [:slug]
    define :list_by_tag, action: :by_tag, args: [:tag]
    define :update_tags, action: :update_tags, args: [:tags]
  end

  # Actions - read and update actions
  actions do
    # Default read action
    defaults [:read]

    # Update action for auto-tagging
    update :update_tags do
      description "Update tags for a post"
      accept [:tags]
    end

    # Custom read actions for specific use cases
    read :published do
      description "Get all published posts"
      filter expr(published == true)
      pagination offset?: true, keyset?: true, default_limit: 10
    end

    read :featured do
      description "Get the latest featured post"
      filter expr(featured == true and published == true)
      pagination offset?: true, keyset?: true, default_limit: 1
    end

    read :by_slug do
      description "Get a post by its slug"
      argument :slug, :string, allow_nil?: false
      filter expr(slug == ^arg(:slug) and published == true)
      get? true
    end

    read :by_tag do
      description "Get posts by tag"
      argument :tag, :string, allow_nil?: false
      filter expr(^arg(:tag) in tags and published == true)
      pagination offset?: true, keyset?: true, default_limit: 10
    end

    read :recent do
      description "Get recent posts ordered by publication date"
      filter expr(published == true)
      pagination offset?: true, keyset?: true, default_limit: 3
    end

    read :all_posts do
      description "Get all posts with pagination for load more functionality"
      filter expr(published == true)
      pagination offset?: true, keyset?: true, default_limit: 6
    end
  end

  # Preparations - modify queries before execution
  preparations do
    prepare build(sort: [published_at: :desc], load: [:href, :published_date_string, :read_time])
  end

  # Attributes - defines the structure of a blog post
  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      description "The title of the blog post"
    end

    attribute :slug, :string do
      allow_nil? false
      description "URL-friendly version of the title"
    end

    attribute :excerpt, :string do
      description "Brief excerpt or summary of the post"
    end

    attribute :content, :string do
      allow_nil? false
      description "Full content of the blog post in markdown format"
    end

    attribute :author, :string do
      allow_nil? false
      description "Author name"
    end

    attribute :author_email, :string do
      description "Author email address"
    end

    attribute :tags, {:array, :string} do
      default []
      description "List of tags associated with the post"
    end

    attribute :featured, :boolean do
      default false
      description "Whether this post is featured"
    end

    attribute :published, :boolean do
      default false
      description "Whether this post is published"
    end

    attribute :published_at, :utc_datetime do
      description "When the post was published"
    end

    attribute :read_time_minutes, :integer do
      description "Estimated reading time in minutes"
    end

    attribute :view_count, :integer do
      default 0
      description "Number of times this post has been viewed"
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  # Calculations - computed attributes
  calculations do
    calculate :href, :string, expr("/posts/" <> slug) do
      description "Full URL path to the post"
    end

    calculate :published_date_string, :string do
      description "Human-readable publication date"

      calculation fn records, _context ->
        Enum.map(records, fn record ->
          case record.published_at do
            nil -> ""
            datetime -> Calendar.strftime(datetime, "%b %d, %Y")
          end
        end)
      end
    end

    calculate :read_time, :string, expr(fragment("? || ' min read'", read_time_minutes)) do
      description "Formatted reading time string"
    end
  end
end
