# frozen_string_literal: true

require 'aws-sdk-s3'
require 'safe_yaml'

class PagesController < ApplicationController
  def initialize
    @curriculum = Curriculum.new
  end

  def home
    cv = @curriculum.find
    render json: cv, status: :ok
  end
end
