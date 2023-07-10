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
TrainStation.destroy_all
dataset = Rails.configuration.trainline_eu_dataset
if not File.exist?(dataset)
	IO.copy_stream open(Rails.configuration.trainline_eu_stations), dataset
end

CSV.foreach dataset, headers: true, col_sep: ';', encoding: 'UTF-8' do |row|
	# puts row
	id_from_trainline = row[:id]
	row.delete :id
	station = TrainStation.new
	station.attributes = {
		**row,
		trainline_id: id_from_trainline,
		info_en: row['info:en'],
		info_es: row['info:es'],
	}.reject{|k,v| !station.attributes.keys.member?(k.to_s) }
	# puts station
	station.save
end
