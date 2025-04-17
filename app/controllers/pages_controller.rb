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

  def top_rated_schools
    @top_rated_schools = School.where("avg_rating >= ?", 4.0).includes(:airport, airport: [ :city, :state ]).order(avg_rating: :desc)

    set_meta_tags title: "Top Rated Flight Schools | Best Reviewed Pilot Training",
                 description: "Browse the highest-rated flight schools based on student reviews and satisfaction scores.",
                 keywords: "top rated flight schools, best reviewed flight training, highly rated pilot schools, best aviation programs"
  end
end
