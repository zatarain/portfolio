# frozen_string_literal: true

require 'csv'
require 'open-uri'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Populating train_stations from trainline data to generate the spatial layer
connection = ActiveRecord::Base.connection
TrainStation.destroy_all
station = TrainStation.new
columns = station.attributes.keys.reject{ |key| key == 'location' }.join(' ')
dataset = Rails.configuration.trainline_eu_dataset
ActiveRecord::Base.transaction do
	connection.execute <<-SQL
		COPY "public"."train_stations"
		FROM '#{dataset}'
		DELIMITER ';'
		CSV HEADER;
	SQL
end
