# frozen_string_literal: true

class ExperiencesController < ApplicationController
  def index
    experiences = [
      {
        id: 1,
        title: 'Software Engineer',
        company: 'Deliveroo',
        city: 'London',
        country: 'UK',
        type: 'full-time',
        from: '13/09/2021',
        to: nil,
        description: 'Hello world 1!'
      },
      {
        id: 2,
        title: 'Software Engineer',
        company: 'Goldman Sachs',
        city: 'London',
        country: 'UK',
        type: 'full-time',
        from: '04/02/2019',
        to: '01/09/2021',
        description: 'Hello world 2!'
      }
    ]
    response.set_header('Access-Control-Allow-Origin', 'https://ulises.zatara.in.dev')
    if experiences
      render json: {
        status: 'SUCCESS',
        message: 'Work experiences successfully fetched.',
        data: experiences
      }, status: :ok
    else
      render json: friends.errors, status: :bad_request
    end
  end
end
