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
  end
end
