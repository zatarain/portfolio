# frozen_string_literal: true

class Stadium < ApplicationRecord
  include GeoLocalisable

  validates :name, presence: true
end
