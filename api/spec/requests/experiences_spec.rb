require 'rails_helper'

RSpec.describe 'Experiences', type: :request do
  describe 'GET /experiences' do
    it 'should response HTTP/200 OK with a JSON' do
      get '/experiences'
      expect(response.status).to eq(200)
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:message]).to eq('Work experiences successfully fetched.')
    end
  end
end
