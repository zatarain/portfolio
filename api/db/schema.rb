# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_10_040341) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "address_standardizer"
  enable_extension "address_standardizer_data_us"
  enable_extension "fuzzystrmatch"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_raster"
  enable_extension "postgis_tiger_geocoder"
  enable_extension "postgis_topology"

# Could not dump table "addrfeat" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "bg" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "county" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "cousub" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "edges" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "faces" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "place" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "state" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "tabblock" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "tabblock20" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4269)' for column 'the_geom'

# Could not dump table "tract" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "zcta5" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

end
