# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development? || Rails.configuration.needs_seeds
  # Populating train_stations from trainline data to generate the spatial layer
  connection = ActiveRecord::Base.connection
  connection.execute('TRUNCATE stadia')
  connection.execute('TRUNCATE train_stations')

  ActiveRecord::Base.transaction do
    connection.execute(File.read(Rails.configuration.trainline_eu_dataset))
  end

  # Populating few initial stadiums
  Stadium.create(
    [
      {
        name: 'Anfield Road',
        slug: 'anfield-road',
        team: 'Liverpool F. C.',
        latitude: 53.43083,
        longitude: -2.96083,
      },
      {
        name: 'Wembley Stadium',
        slug: 'wembley-stadium',
        team: 'England National Football Team',
        latitude: 51.555556,
        longitude: -0.279444,
      },
      {
        name: 'Hampden Park',
        slug: 'hampden-park',
        team: 'Scotland National Football Team',
        latitude: 55.8259,
        longitude: -4.2520,
      },
      {
        name: 'Millennium Stadium',
        slug: 'millennium-stadium',
        team: 'Wales National Football Team',
        latitude: 51.4781,
        longitude: -3.1825,
      },
    ],
  )
end
