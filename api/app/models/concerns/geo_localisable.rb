# frozen_string_literal: true

module GeoLocalisable
  extend ActiveSupport::Concern

  included do
    validates :latitude, presence: true
    validates :longitude, presence: true
    validates :location, presence: true
    before_validation :set_location

    def set_location
      self[:location] = self.class.geographic.point(self[:longitude], self[:latitude])
    end
  end

  class_methods do
    def geographic
      @geographic ||= RGeo::Geographic.spherical_factory(
        srid: Rails.configuration.spatial_reference_system,
      )
    end
  end
end
