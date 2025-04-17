class PagesController < ApplicationController
  def home
  end

  def confirmation_pending
    # Confirmation pending page
  end

  def account_confirmed
    # page saying that user was successfully created
  end

  def featured_schools
    @featured_schools = School.where(featured: true).includes(:airport, airport: [ :city, :state ]).order(created_at: :desc)

    set_meta_tags title: "Featured Flight Schools | Find Top Pilot Training Programs",
                 description: "Discover our handpicked selection of top flight schools across the country offering exceptional pilot training programs.",
                 keywords: "featured flight schools, best flight training, top pilot schools, aviation training programs"
  end
end
