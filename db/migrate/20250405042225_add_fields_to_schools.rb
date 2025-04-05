class AddFieldsToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :description, :text
    add_column :schools, :est_planes, :integer
    add_column :schools, :est_cfis, :integer
    add_column :schools, :part_141, :boolean, default: false, null: false
    add_column :schools, :part_61, :boolean, default: false, null: false
    add_column :schools, :training_types, :string, array: true, default: [], null: false
    add_column :schools, :accelerated_programs, :boolean, default: false, null: false
    add_column :schools, :examining_authority, :boolean, default: false, null: false
    add_column :schools, :date_established, :date
    add_column :schools, :featured, :boolean, default: false, null: false
    add_column :schools, :approved, :boolean, default: true, null: false
  end
end