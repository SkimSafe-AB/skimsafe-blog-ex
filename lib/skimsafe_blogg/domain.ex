defmodule SkimsafeBlogg.Domain do
  @moduledoc """
  The SkimsafeBlogg domain for managing blog-related resources.
  """
  use Ash.Domain, otp_app: :skimsafe_blogg

  resources do
    resource SkimsafeBlogg.Resources.Post
  end
end
