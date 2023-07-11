# frozen_string_literal: true

class CreateStadia < ActiveRecord::Migration[7.0]
  def change
    create_table :stadia, id: :serial, force: :cascade do |column|
      column.string :name, limit: 255
      column.string :slug, limit: 63
      column.float :latitude
      column.float :longitude
      column.st_point :location, geographic: true, srid: Rails.configuration.spatial_reference_system
      column.string :team, limit: 255
      column.timestamps
    end
  end
end
