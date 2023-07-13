# frozen_string_literal: true

class StationsController < ApplicationController
  def index
    @station = TrainStation.new
    render json: TrainStation.within_box(
      @station.point(49.000000, -7.00000),
      @station.point(60.000000,  7.00000),
    ), status: :ok
  rescue StandardError => exception
    Rails.logger.error "Failed to find data: #{exception.message}"
    render status: :internal_server_error
  end

  def new
    @station = TrainStation.new
  end

  def create
    @station = TrainStation.new(fields)
    if @station.save!
      render json: @station, status: :ok
    else
      render :new, status: :bad_request
    end
  rescue StandardError => exception
    Rails.logger.error "Failed to save data: #{exception.message}"
    render status: :internal_server_error
  end

  private

  def fields
    params.require(:station).permit(
      :name,
      :slug,
      :latitude,
      :longitude,
      :country,
      :time_zone,
      :info_en,
      :info_es,
    )
  end
end
