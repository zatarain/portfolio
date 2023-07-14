# frozen_string_literal: true

require 'rails_helper'

describe TrainStation, type: :model do
  context 'when all fields are valid' do
    it 'save the station with generated location in the datbase' do
      station = described_class.create(
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
      expect(station.location).to be_present
      expect(station.location.x).to eq(-0.01861)
      expect(station.location.y).to eq(51.50361)
    end
  end

  context 'when there are invalid fields' do
    it 'does NOT save when the name is empty' do
      station = described_class.create(
        name: '',
        slug: 'canary-wharf',
        country: 'GB',
        time_zone: 'Europe/London',
        latitude: 51.50361,
        longitude: -0.01861,
        info_en: 'London Underground Station',
        info_es: 'Estación del Metro de Londres',
      )

      expect(station.id).not_to be_present
    end

    it 'does NOT save when the latitude is not present' do
      station = described_class.create(
        name: 'Canary Wharf',
        slug: 'canary-wharf',
        country: 'GB',
        time_zone: 'Europe/London',
        longitude: -0.01861,
        info_en: 'London Underground Station',
        info_es: 'Estación del Metro de Londres',
      )

      expect(station.id).not_to be_present
    end

    it 'does NOT save when the longitude is not present' do
      station = described_class.create(
        name: 'Canary Wharf',
        slug: 'canary-wharf',
        country: 'GB',
        time_zone: 'Europe/London',
        latitude: -0.01861,
        info_en: 'London Underground Station',
        info_es: 'Estación del Metro de Londres',
      )

      expect(station.id).not_to be_present
    end

    it 'does NOT save when the latitude is out of range -90..90' do
      station = described_class.create(
        name: 'Canary Wharf',
        slug: 'canary-wharf',
        country: 'GB',
        time_zone: 'Europe/London',
        latitude: 90.5231,
        longitude: -0.01861,
        info_en: 'London Underground Station',
        info_es: 'Estación del Metro de Londres',
      )

      expect(station.id).not_to be_present
    end

    it 'does NOT save when the longitude is out of range -180..180' do
      station = described_class.create(
        name: 'Canary Wharf',
        slug: 'canary-wharf',
        country: 'GB',
        time_zone: 'Europe/London',
        latitude: -0.01861,
        longitude: -180.5564,
        info_en: 'London Underground Station',
        info_es: 'Estación del Metro de Londres',
      )

      expect(station.id).not_to be_present
    end
  end
end
