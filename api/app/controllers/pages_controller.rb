# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @curriculum = Curriculum.new
    cv = @curriculum.find
    render json: cv, status: :ok
  end
end
