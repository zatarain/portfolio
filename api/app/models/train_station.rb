# frozen_string_literal: true

class TrainStation < ApplicationRecord
  include GeoLocalisable

  validates :name, presence: true
end
