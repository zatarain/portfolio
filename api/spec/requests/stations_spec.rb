# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stations' do
  describe 'GET /index' do
    data = [
      {
        id: 1,
        name: 'Canary Wharf',
        slug: 'canary-wharf',
        country: 'GB',
        time_zone: 'Europe/London',
        latitude: 51.50361,
        longitude: -0.01861,
        info_en: 'London Underground Station',
      },
      {
        id: 2,
        name: 'North Greenwich',
        slug: 'north-greenwich',
        country: 'GB',
        time_zone: 'Europe/London',
        latitude: 51.50037,
        longitude: 0.00433,
        info_en: 'London Underground Station',
      },
    ]

    it 'responses with JSON data on body describing the spatial layer' do
      station = instance_double(TrainStation)
      allow(station).to receive(:point) { |latitude, longitude| [latitude, longitude] }
      allow(TrainStation).to receive(:new).and_return(station)
      allow(TrainStation).to receive(:within_box).and_return(data)
      get '/stations'
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(data.to_json)
      expect(TrainStation).to  have_received(:within_box)
        .with([49.000000, -7.0000], [60.000000, 7.00000])
    end
  end
end
