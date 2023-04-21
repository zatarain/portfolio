# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    render json: {
      name: 'Ulises Tirado Zatarain',
      emails: [
        'u*****o@gmail.com',
        'u*****o@cimat.mx'
      ],
      phones: [
        '+44 07 (XXX) XXX XXX',
        '+52 1 (XXX) XXX XXXX'
      ],
      websites: [
        'https://github.com/zatarain'
      ],
      statement: '',
      experiences: [],
      qualifications: [],
      projects: [],
      skills: [],
      awards: [],
      volunteering: []
    }, status: :ok
  end
end
