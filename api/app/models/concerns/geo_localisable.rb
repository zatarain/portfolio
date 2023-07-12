# frozen_string_literal: true

module GeoLocalisable
  extend ActiveSupport::Concern

  # Taking Spatial Reference System from configuration
  SRID = Rails.configuration.spatial_reference_system

  included do
    validates :latitude, presence: true
    validates :longitude, presence: true
    validates :location, presence: true
    before_validation :set_location

    def point(latitude, longitude)
      self.class.geographic.point(longitude, latitude)
    end

    def set_location
      self[:location] = point(self[:latitude], self[:longitude])
    end
  end

  class_methods do
    def geographic
      @geographic ||= RGeo::Geographic.spherical_factory(srid: SRID)
    end

    def within_box(south_west, north_east)
      box_envelope = <<-POSTGIS.squish
        location && ST_MakeEnvelope(
          :south_west_longitude, :south_west_latitude,
          :north_east_longitude, :north_east_latitude,
          #{SRID}
        )
      POSTGIS
      where box_envelope, {
        south_west_latitude: south_west.y,
        south_west_longitude: south_west.x,
        north_east_latitude: north_east.y,
        north_east_longitude: north_east.x,
      }
    end
  end
end
