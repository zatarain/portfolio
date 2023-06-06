# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Experiences', type: :request do
  describe 'GET /experiences' do
    it 'responses with JSON data on body' do
      get '/experiences'
      json = response.parsed_body.deep_symbolize_keys
      expect(json[:message]).to eq('Work experiences successfully fetched.')
      expect(response.status).to eq(200)
    end
  end
end
