# frozen_string_literal: true

require 'rails_helper'

describe Stadium do
  context 'when all fields are valid' do
    it 'save the stadium with generated location in the datbase' do
      stadium = described_class.create!(
        name: 'Phillips Stadium',
        slug: 'phillips-stadium',
        team: 'PSV Eindhoven',
        latitude: 51.441781,
        longitude: 5.467442,
      )

      expect(stadium.id).to be_present
      expect(stadium.location).to be_present
      expect(stadium.location.x).to eq(5.467442)
      expect(stadium.location.y).to eq(51.441781)
    end
  end
end
