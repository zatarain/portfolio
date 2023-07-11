# frozen_string_literal: true

require 'rails_helper'

describe TrainStation, type: :model do
  context 'when all fields are valid' do
    it 'save the station with generated location in the datbase' do
      station = described_class.create!(
        name: 'Canary Wharf',
        slug: 'canary-wharf',
        country: 'GB',
        time_zone: 'Europe/London',
        latitude: 51.50361,
        longitude: -0.01861,
        info_en: 'London Underground Station',
        info_es: 'Estación del Metro de Londres',
      )
      expect(station.id).to be_present
    end
  end
end
