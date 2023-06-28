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
      },
    ]

    if experiences
      render json: {
        status: 'SUCCESS',
        message: 'Work experiences successfully fetched.',
        data: experiences,
      }, status: :ok
    else
      render json: friends.errors, status: :bad_request
    end
  end
end
