class TrainStations < ActiveRecord::Migration[7.0]
  def change
    create_table :train_stations, id: :serial, force: :cascade do |column|
      column.integer :trainline_id
      column.string :name, limit: 255
      column.string :slug, limit: 63
      column.float :latitude, null: false
      column.float :longitude, null: false
      column.st_point :location, geographic: true, srid: 4326
      column.integer :parent_station_id
      column.string :country, limit: 2
      column.string :time_zone, limit: 64
      column.boolean :is_city
      column.boolean :is_main_station
      column.boolean :is_airport
      column.boolean :is_suggestable
      column.boolean :country_hint
      column.boolean :main_station_hint
      column.integer :same_as
      column.text :info_en
      column.text :info_es
      column.string :normalised_code, limit: 40
      column.string :iata_airport_code, limit: 3

      column.index :name
      column.index %i[latitude longitude]
      column.index :location, using: :gist
      column.index :country
      column.index :time_zone
      column.index :iata_airport_code
      column.index :normalised_code
    end
  end
end
