# frozen_string_literal: true

require 'rails_helper'

describe Stadium, type: :model do
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
    end
  end
end
