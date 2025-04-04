class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_default_meta_tags

  private

  def set_default_meta_tags
    set_meta_tags(
      title: "Pilot Training Near Me | Flight School Directory",
      description: "Find top flight schools and aviation academies across the US for pilot training and aviation education.",
      keywords: "flight schools, pilot training, aviation directory",
      charset: "utf-8",
      viewport: "width=device-width, initial-scale=1"
    )
  end
end
