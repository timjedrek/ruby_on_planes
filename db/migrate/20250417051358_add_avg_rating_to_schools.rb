class AddAvgRatingToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :avg_rating, :decimal, precision: 3, scale: 1
  end
end
