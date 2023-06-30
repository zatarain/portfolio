# frozen_string_literal: true

require 'rails_helper'

describe 'Pages', type: :request do
  describe 'GET /' do
    data = {
      name: 'My Test Name',
      statement: 'This is a dummy statement paragraph',
      'work-experience': [
        {
          role: 'Dummy Role',
          type: 'full-time',
          company: 'Dummy Company',
          city: 'Dummy City',
          country: 'Dummy Country',
        },
        {
          role: 'Dummy Role Inter',
          type: 'part-time',
          company: 'Dummy Company',
          city: 'Another City',
          country: 'Same Country',
        },
      ],
      awards: [
        'dummy award one',
        'dummy award two',
      ],
    }

    it 'responses with JSON curriculum data on body' do
      curriculum = instance_double(Curriculum, find: data)
      allow(Curriculum).to receive(:new).and_return(curriculum)
      get '/'
      expect(response.status).to eq(200)
      expect(response.body).to eq(data.to_json)
    end

    it 'logs error message and responses with HTTP 500 on error finding the data' do
      curriculum = instance_double(Curriculum)
      allow(curriculum).to receive(:find)
        .and_raise(StandardError.new('Unable to find curriculum data'))
      allow(Curriculum).to receive(:new).and_return(curriculum)
      allow(Rails.logger).to receive(:error)
      get '/'
      expect(response.status).to eq(500)
      expect(Rails.logger).to have_received(:error)
        .with(/Unable to find curriculum data/)
    end
  end
end
