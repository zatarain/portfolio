# frozen_string_literal: true

require 'aws-sdk-s3'
require 'safe_yaml'

class PagesController < ApplicationController
  def home
    @curriculum = Curriculum.new
    cv = @curriculum.find
    render json: cv, status: :ok
  end
end
