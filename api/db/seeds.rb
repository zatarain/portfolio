# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

unless Rails.env.production?
  # Populating train_stations from trainline data to generate the spatial layer
  connection = ActiveRecord::Base.connection
  TrainStation.destroy_all
  connection.execute('TRUNCATE train_stations')

  ActiveRecord::Base.transaction do
    connection.execute(File.read(Rails.configuration.trainline_eu_dataset))
  end
end
