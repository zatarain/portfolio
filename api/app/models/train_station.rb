# frozen_string_literal: true

class TrainStation < ApplicationRecord
  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :location, presence: true

  before_validation :set_location

  class << self
    def self.geographic
      @geographic ||= RGeo::Geographic.spherical_factory(srid: Rails.configuration.spatial_reference_system)
    end
  end

  private

  def set_location
    geographic ||= RGeo::Geographic.spherical_factory(srid: Rails.configuration.spatial_reference_system)
    self[:location] = geographic.point(self[:longitude], self[:latitude])
  end
end
