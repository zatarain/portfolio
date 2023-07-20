# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stations' do
  describe 'GET /stations' do
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

    it 'logs error message and responses with HTTP 500 on error finding the data' do
      station = instance_double(TrainStation)
      allow(station).to receive(:point) { |latitude, longitude| [latitude, longitude] }
      allow(TrainStation).to receive(:within_box)
        .and_raise(StandardError.new('Unable to find the data for train stations'))
      allow(TrainStation).to receive(:new).and_return(station)
      allow(Rails.logger).to receive(:error)

      get '/stations'

      expect(response).to have_http_status(:internal_server_error)
      expect(Rails.logger).to have_received(:error)
        .with(/Unable to find the data for train stations/)
    end
  end

  describe 'POST /stations' do
    let(:station) do
      {
        name: 'Canary Wharf',
        slug: 'canary-wharf',
        country: 'GB',
        time_zone: 'Europe/London',
        latitude: 51.50361,
        longitude: -0.01861,
        info_en: 'London Underground Station',
        info_es: 'Estación del Metro de Londres',
      }
    end

    it 'responses with HTTP 400 and JSON data on body describing new point when data is saved' do
      post '/stations', params: { station: }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to match(hash_including(station.stringify_keys))
      expect(body.keys).to match(array_including(%w[id location created_at updated_at]))
    end

    context 'when fields are invalid' do
      [
        [:name, ['can\'t be blank']],
        [:latitude, ['can\'t be blank', 'is not a number']],
        [:longitude, ['can\'t be blank', 'is not a number']],
      ].each do |field, message|
        it "responses with JSON on body describing error when #{field} is missing" do
          post '/stations', params: { station: station.reject { |key| key == field } }

          expect(response).to have_http_status(:bad_request)
          body = response.parsed_body
          expect(body).to match(hash_including({ field => message }.stringify_keys))
        end
      end

      [
        [:latitude, 91, ['must be in -90..90']],
        [:longitude, 181, ['must be in -180..180']],
        [:latitude, -91, ['must be in -90..90']],
        [:longitude, -181, ['must be in -180..180']],
      ].each do |field, value, message|
        it "responses with JSON on body describing error when #{field} is out of range" do
          station[field] = value

          post '/stations', params: { station: }

          expect(response).to have_http_status(:bad_request)
          body = response.parsed_body
          expect(body).to match(hash_including({ field => message }.stringify_keys))
        end
      end
    end

    context 'when there is an exception' do
      it 'responses with HTTP 500' do
        allow(TrainStation).to receive(:new).and_raise(
          StandardError.new('Unable to save the data for train stations'),
        )
        allow(Rails.logger).to receive(:error)

        post '/stations', params: { station: }

        expect(response).to have_http_status(:internal_server_error)
        expect(Rails.logger).to have_received(:error)
          .with(/Unable to save the data for train stations/)
      end
    end
  end

  describe 'DELETE /stations/:id' do
    it 'responses with HTTP 200 when record is successfully deleted' do
      station = instance_double(TrainStation)
      allow(station).to receive(:destroy).and_return(true)
      allow(TrainStation).to receive(:find).and_return(station)

      delete '/stations/4'

      expect(response).to have_http_status(:ok)
    end

    it 'responses with HTTP 404 when record is not found' do
      allow(TrainStation).to receive(:find)
        .and_raise(ActiveRecord::RecordNotFound.new('Not found'))

      delete '/stations/444444'

      expect(response).to have_http_status(:not_found)
    end

    it 'responses with HTTP 500 when there is any other exception' do
      station = instance_double(TrainStation)
      allow(station).to receive(:destroy).and_return(false)
      allow(TrainStation).to receive(:find).and_return(station)
      allow(Rails.logger).to receive(:error)

      delete '/stations/4'

      expect(response).to have_http_status(:internal_server_error)
      expect(Rails.logger).to have_received(:error)
        .with(/Unknown error/)
    end
  end
end
