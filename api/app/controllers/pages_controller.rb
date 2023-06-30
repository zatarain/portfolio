# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @curriculum = Curriculum.new
    cv = @curriculum.find
    render json: cv, status: :ok
  rescue StandardError => exception
    Rails.logger.error "Failed to find data: #{exception.message}"
    render status: :internal_server_error
  end
end
