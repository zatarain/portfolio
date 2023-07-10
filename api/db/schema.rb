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

ActiveRecord::Schema[7.0].define(version: 2023_07_10_180003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "address_standardizer"
  enable_extension "address_standardizer_data_us"
  enable_extension "fuzzystrmatch"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_raster"
  enable_extension "postgis_tiger_geocoder"
  enable_extension "postgis_topology"

  create_table "addrfeat", primary_key: "gid", id: :serial, force: :cascade do |t|
    t.bigint "tlid"
    t.string "statefp", limit: 2, null: false
    t.string "aridl", limit: 22
    t.string "aridr", limit: 22
    t.string "linearid", limit: 22
    t.string "fullname", limit: 100
    t.string "lfromhn", limit: 12
    t.string "ltohn", limit: 12
    t.string "rfromhn", limit: 12
    t.string "rtohn", limit: 12
    t.string "zipl", limit: 5
    t.string "zipr", limit: 5
    t.string "edge_mtfcc", limit: 5
    t.string "parityl", limit: 1
    t.string "parityr", limit: 1
    t.string "plus4l", limit: 4
    t.string "plus4r", limit: 4
    t.string "lfromtyp", limit: 1
    t.string "ltotyp", limit: 1
    t.string "rfromtyp", limit: 1
    t.string "rtotyp", limit: 1
    t.string "offsetl", limit: 1
    t.string "offsetr", limit: 1
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.index ["the_geom"], name: "idx_addrfeat_geom_gist", using: :gist
    t.index ["tlid"], name: "idx_addrfeat_tlid"
    t.index ["zipl"], name: "idx_addrfeat_zipl"
    t.index ["zipr"], name: "idx_addrfeat_zipr"
    t.check_constraint "geometrytype(the_geom) = 'LINESTRING'::text OR the_geom IS NULL", name: "enforce_geotype_the_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_the_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_the_geom"
  end

  create_table "bg", primary_key: "bg_id", id: { type: :string, limit: 12 }, comment: "block groups", force: :cascade do |t|
    t.serial "gid", null: false
    t.string "statefp", limit: 2
    t.string "countyfp", limit: 3
    t.string "tractce", limit: 6
    t.string "blkgrpce", limit: 1
    t.string "namelsad", limit: 13
    t.string "mtfcc", limit: 5
    t.string "funcstat", limit: 1
    t.float "aland"
    t.float "awater"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_geom"
  end

  create_table "county", primary_key: "cntyidfp", id: { type: :string, limit: 5 }, force: :cascade do |t|
    t.serial "gid", null: false
    t.string "statefp", limit: 2
    t.string "countyfp", limit: 3
    t.string "countyns", limit: 8
    t.string "name", limit: 100
    t.string "namelsad", limit: 100
    t.string "lsad", limit: 2
    t.string "classfp", limit: 2
    t.string "mtfcc", limit: 5
    t.string "csafp", limit: 3
    t.string "cbsafp", limit: 5
    t.string "metdivfp", limit: 5
    t.string "funcstat", limit: 1
    t.bigint "aland"
    t.float "awater"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.index ["countyfp"], name: "idx_tiger_county"
    t.index ["gid"], name: "uidx_county_gid", unique: true
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_geom"
  end

  create_table "cousub", primary_key: "cosbidfp", id: { type: :string, limit: 10 }, force: :cascade do |t|
    t.serial "gid", null: false
    t.string "statefp", limit: 2
    t.string "countyfp", limit: 3
    t.string "cousubfp", limit: 5
    t.string "cousubns", limit: 8
    t.string "name", limit: 100
    t.string "namelsad", limit: 100
    t.string "lsad", limit: 2
    t.string "classfp", limit: 2
    t.string "mtfcc", limit: 5
    t.string "cnectafp", limit: 3
    t.string "nectafp", limit: 5
    t.string "nctadvfp", limit: 5
    t.string "funcstat", limit: 1
    t.decimal "aland", precision: 14
    t.decimal "awater", precision: 14
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.index ["gid"], name: "uidx_cousub_gid", unique: true
    t.index ["the_geom"], name: "tige_cousub_the_geom_gist", using: :gist
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_the_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_the_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_the_geom"
  end

  create_table "edges", primary_key: "gid", id: :serial, force: :cascade do |t|
    t.string "statefp", limit: 2
    t.string "countyfp", limit: 3
    t.bigint "tlid"
    t.decimal "tfidl", precision: 10
    t.decimal "tfidr", precision: 10
    t.string "mtfcc", limit: 5
    t.string "fullname", limit: 100
    t.string "smid", limit: 22
    t.string "lfromadd", limit: 12
    t.string "ltoadd", limit: 12
    t.string "rfromadd", limit: 12
    t.string "rtoadd", limit: 12
    t.string "zipl", limit: 5
    t.string "zipr", limit: 5
    t.string "featcat", limit: 1
    t.string "hydroflg", limit: 1
    t.string "railflg", limit: 1
    t.string "roadflg", limit: 1
    t.string "olfflg", limit: 1
    t.string "passflg", limit: 1
    t.string "divroad", limit: 1
    t.string "exttyp", limit: 1
    t.string "ttyp", limit: 1
    t.string "deckedroad", limit: 1
    t.string "artpath", limit: 1
    t.string "persist", limit: 1
    t.string "gcseflg", limit: 1
    t.string "offsetl", limit: 1
    t.string "offsetr", limit: 1
    t.decimal "tnidf", precision: 10
    t.decimal "tnidt", precision: 10
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.index ["countyfp"], name: "idx_tiger_edges_countyfp"
    t.index ["the_geom"], name: "idx_tiger_edges_the_geom_gist", using: :gist
    t.index ["tlid"], name: "idx_edges_tlid"
    t.check_constraint "geometrytype(the_geom) = 'MULTILINESTRING'::text OR the_geom IS NULL", name: "enforce_geotype_the_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_the_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_the_geom"
  end

  create_table "eu_estations", primary_key: "ogc_fid", id: :serial, force: :cascade do |t|
    t.geometry "location", limit: {:srid=>4326, :type=>"st_point"}
    t.decimal "id", precision: 10
    t.string "name"
    t.string "slug"
    t.decimal "uic", precision: 10
    t.decimal "uic8_sncf", precision: 10
    t.float "latitude"
    t.float "longitude"
    t.decimal "parent_station_id", precision: 10
    t.string "country"
    t.string "time_zone"
    t.boolean "is_city"
    t.boolean "is_main_station"
    t.boolean "is_airport"
    t.boolean "is_suggestable"
    t.boolean "country_hint"
    t.boolean "main_station_hint"
    t.string "sncf_id"
    t.string "sncf_tvs_id"
    t.boolean "sncf_is_enabled"
    t.string "entur_id"
    t.boolean "entur_is_enabled"
    t.decimal "db_id", precision: 10
    t.boolean "db_is_enabled"
    t.string "busbud_id"
    t.boolean "busbud_is_enabled"
    t.string "distribusion_id"
    t.boolean "distribusion_is_enabled"
    t.decimal "flixbus_id", precision: 10
    t.boolean "flixbus_is_enabled"
    t.decimal "cff_id", precision: 10
    t.boolean "cff_is_enabled"
    t.string "leoexpress_id"
    t.boolean "leoexpress_is_enabled"
    t.decimal "obb_id", precision: 10
    t.boolean "obb_is_enabled"
    t.string "ouigo_id"
    t.boolean "ouigo_is_enabled"
    t.decimal "trenitalia_id", precision: 10
    t.boolean "trenitalia_is_enabled"
    t.string "trenitalia_rtvt_id"
    t.decimal "ntv_rtiv_id", precision: 10
    t.string "ntv_id"
    t.boolean "ntv_is_enabled"
    t.decimal "hkx_id", precision: 10
    t.boolean "hkx_is_enabled"
    t.string "renfe_id"
    t.boolean "renfe_is_enabled"
    t.string "atoc_id"
    t.boolean "atoc_is_enabled"
    t.string "benerail_id"
    t.boolean "benerail_is_enabled"
    t.decimal "westbahn_id", precision: 10
    t.boolean "westbahn_is_enabled"
    t.boolean "sncf_self_service_machine"
    t.decimal "same_as", precision: 10
    t.string "info:de"
    t.string "info:en"
    t.string "info:es"
    t.string "info:fr"
    t.string "info:it"
    t.string "info:nb"
    t.string "info:nl"
    t.string "info:cs"
    t.string "info:da"
    t.string "info:hu"
    t.string "info:ja"
    t.string "info:ko"
    t.string "info:pl"
    t.string "info:pt"
    t.string "info:ru"
    t.string "info:sv"
    t.string "info:tr"
    t.string "info:zh"
    t.string "normalised_code"
    t.string "iata_airport_code"
    t.index ["location"], name: "eu_estations_location_geom_idx", using: :gist
  end

  create_table "eu_stations", id: :integer, default: nil, force: :cascade do |t|
    t.geometry "geom", limit: {:srid=>4326, :type=>"st_point"}
    t.string "name"
    t.string "slug"
    t.integer "uic"
    t.integer "uic8_sncf"
    t.float "latitude"
    t.float "longitude"
    t.integer "parent_station_id"
    t.string "country"
    t.string "time_zone"
    t.boolean "is_city"
    t.boolean "is_main_station"
    t.boolean "is_airport"
    t.boolean "is_suggestable"
    t.boolean "country_hint"
    t.boolean "main_station_hint"
    t.string "sncf_id"
    t.string "sncf_tvs_id"
    t.boolean "sncf_is_enabled"
    t.string "entur_id"
    t.boolean "entur_is_enabled"
    t.integer "db_id"
    t.boolean "db_is_enabled"
    t.string "busbud_id"
    t.boolean "busbud_is_enabled"
    t.string "distribusion_id"
    t.boolean "distribusion_is_enabled"
    t.integer "flixbus_id"
    t.boolean "flixbus_is_enabled"
    t.integer "cff_id"
    t.boolean "cff_is_enabled"
    t.string "leoexpress_id"
    t.boolean "leoexpress_is_enabled"
    t.integer "obb_id"
    t.boolean "obb_is_enabled"
    t.string "ouigo_id"
    t.boolean "ouigo_is_enabled"
    t.integer "trenitalia_id"
    t.boolean "trenitalia_is_enabled"
    t.string "trenitalia_rtvt_id"
    t.integer "ntv_rtiv_id"
    t.string "ntv_id"
    t.boolean "ntv_is_enabled"
    t.integer "hkx_id"
    t.boolean "hkx_is_enabled"
    t.string "renfe_id"
    t.boolean "renfe_is_enabled"
    t.string "atoc_id"
    t.boolean "atoc_is_enabled"
    t.string "benerail_id"
    t.boolean "benerail_is_enabled"
    t.integer "westbahn_id"
    t.boolean "westbahn_is_enabled"
    t.boolean "sncf_self_service_machine"
    t.integer "same_as"
    t.string "info:de"
    t.string "info:en"
    t.string "info:es"
    t.string "info:fr"
    t.string "info:it"
    t.string "info:nb"
    t.string "info:nl"
    t.string "info:cs"
    t.string "info:da"
    t.string "info:hu"
    t.string "info:ja"
    t.string "info:ko"
    t.string "info:pl"
    t.string "info:pt"
    t.string "info:ru"
    t.string "info:sv"
    t.string "info:tr"
    t.string "info:zh"
    t.string "normalised_code"
    t.string "iata_airport_code"
  end

  create_table "faces", primary_key: "gid", id: :serial, force: :cascade do |t|
    t.decimal "tfid", precision: 10
    t.string "statefp00", limit: 2
    t.string "countyfp00", limit: 3
    t.string "tractce00", limit: 6
    t.string "blkgrpce00", limit: 1
    t.string "blockce00", limit: 4
    t.string "cousubfp00", limit: 5
    t.string "submcdfp00", limit: 5
    t.string "conctyfp00", limit: 5
    t.string "placefp00", limit: 5
    t.string "aiannhfp00", limit: 5
    t.string "aiannhce00", limit: 4
    t.string "comptyp00", limit: 1
    t.string "trsubfp00", limit: 5
    t.string "trsubce00", limit: 3
    t.string "anrcfp00", limit: 5
    t.string "elsdlea00", limit: 5
    t.string "scsdlea00", limit: 5
    t.string "unsdlea00", limit: 5
    t.string "uace00", limit: 5
    t.string "cd108fp", limit: 2
    t.string "sldust00", limit: 3
    t.string "sldlst00", limit: 3
    t.string "vtdst00", limit: 6
    t.string "zcta5ce00", limit: 5
    t.string "tazce00", limit: 6
    t.string "ugace00", limit: 5
    t.string "puma5ce00", limit: 5
    t.string "statefp", limit: 2
    t.string "countyfp", limit: 3
    t.string "tractce", limit: 6
    t.string "blkgrpce", limit: 1
    t.string "blockce", limit: 4
    t.string "cousubfp", limit: 5
    t.string "submcdfp", limit: 5
    t.string "conctyfp", limit: 5
    t.string "placefp", limit: 5
    t.string "aiannhfp", limit: 5
    t.string "aiannhce", limit: 4
    t.string "comptyp", limit: 1
    t.string "trsubfp", limit: 5
    t.string "trsubce", limit: 3
    t.string "anrcfp", limit: 5
    t.string "ttractce", limit: 6
    t.string "tblkgpce", limit: 1
    t.string "elsdlea", limit: 5
    t.string "scsdlea", limit: 5
    t.string "unsdlea", limit: 5
    t.string "uace", limit: 5
    t.string "cd111fp", limit: 2
    t.string "sldust", limit: 3
    t.string "sldlst", limit: 3
    t.string "vtdst", limit: 6
    t.string "zcta5ce", limit: 5
    t.string "tazce", limit: 6
    t.string "ugace", limit: 5
    t.string "puma5ce", limit: 5
    t.string "csafp", limit: 3
    t.string "cbsafp", limit: 5
    t.string "metdivfp", limit: 5
    t.string "cnectafp", limit: 3
    t.string "nectafp", limit: 5
    t.string "nctadvfp", limit: 5
    t.string "lwflag", limit: 1
    t.string "offset", limit: 1
    t.float "atotal"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.string "tractce20", limit: 6
    t.string "blkgrpce20", limit: 1
    t.string "blockce20", limit: 4
    t.string "countyfp20", limit: 3
    t.string "statefp20", limit: 2
    t.index ["countyfp"], name: "idx_tiger_faces_countyfp"
    t.index ["tfid"], name: "idx_tiger_faces_tfid"
    t.index ["the_geom"], name: "tiger_faces_the_geom_gist", using: :gist
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_the_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_the_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_the_geom"
  end

  create_table "place", primary_key: "plcidfp", id: { type: :string, limit: 7 }, force: :cascade do |t|
    t.serial "gid", null: false
    t.string "statefp", limit: 2
    t.string "placefp", limit: 5
    t.string "placens", limit: 8
    t.string "name", limit: 100
    t.string "namelsad", limit: 100
    t.string "lsad", limit: 2
    t.string "classfp", limit: 2
    t.string "cpi", limit: 1
    t.string "pcicbsa", limit: 1
    t.string "pcinecta", limit: 1
    t.string "mtfcc", limit: 5
    t.string "funcstat", limit: 1
    t.bigint "aland"
    t.bigint "awater"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.index ["gid"], name: "uidx_tiger_place_gid", unique: true
    t.index ["the_geom"], name: "tiger_place_the_geom_gist", using: :gist
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_the_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_the_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_the_geom"
  end

  create_table "railway_stations", primary_key: "ogc_fid", id: :serial, force: :cascade do |t|
    t.geometry "location", limit: {:srid=>4326, :type=>"st_point"}
    t.string "name"
    t.string "slug"
    t.decimal "uic", precision: 10
    t.decimal "uic8_sncf", precision: 10
    t.float "latitude"
    t.float "longitude"
    t.decimal "parent_station_id", precision: 10
    t.string "country"
    t.string "time_zone"
    t.boolean "is_city"
    t.boolean "is_main_station"
    t.boolean "is_airport"
    t.boolean "is_suggestable"
    t.boolean "country_hint"
    t.boolean "main_station_hint"
    t.string "sncf_id"
    t.string "sncf_tvs_id"
    t.boolean "sncf_is_enabled"
    t.string "entur_id"
    t.boolean "entur_is_enabled"
    t.decimal "db_id", precision: 10
    t.boolean "db_is_enabled"
    t.string "busbud_id"
    t.boolean "busbud_is_enabled"
    t.string "distribusion_id"
    t.boolean "distribusion_is_enabled"
    t.decimal "flixbus_id", precision: 10
    t.boolean "flixbus_is_enabled"
    t.decimal "cff_id", precision: 10
    t.boolean "cff_is_enabled"
    t.string "leoexpress_id"
    t.boolean "leoexpress_is_enabled"
    t.decimal "obb_id", precision: 10
    t.boolean "obb_is_enabled"
    t.string "ouigo_id"
    t.boolean "ouigo_is_enabled"
    t.decimal "trenitalia_id", precision: 10
    t.boolean "trenitalia_is_enabled"
    t.string "trenitalia_rtvt_id"
    t.decimal "ntv_rtiv_id", precision: 10
    t.string "ntv_id"
    t.boolean "ntv_is_enabled"
    t.decimal "hkx_id", precision: 10
    t.boolean "hkx_is_enabled"
    t.string "renfe_id"
    t.boolean "renfe_is_enabled"
    t.string "atoc_id"
    t.boolean "atoc_is_enabled"
    t.string "benerail_id"
    t.boolean "benerail_is_enabled"
    t.decimal "westbahn_id", precision: 10
    t.boolean "westbahn_is_enabled"
    t.boolean "sncf_self_service_machine"
    t.decimal "same_as", precision: 10
    t.string "info:en"
    t.string "info:es"
    t.string "normalised_code"
    t.string "iata_airport_code"
    t.index ["location"], name: "railway_stations_location_geom_idx", using: :gist
  end

  create_table "railway_stations_shp", id: :bigint, default: nil, force: :cascade do |t|
    t.geometry "location", limit: {:srid=>4326, :type=>"st_point"}
    t.string "name", limit: 254
    t.string "slug", limit: 254
    t.bigint "uic"
    t.bigint "uic8_sncf"
    t.decimal "latitude"
    t.decimal "longitude"
    t.bigint "parent_sta"
    t.string "country", limit: 254
    t.string "time_zone", limit: 254
    t.integer "is_city"
    t.integer "is_main_st"
    t.integer "is_airport"
    t.integer "is_suggest"
    t.integer "country_hi"
    t.integer "main_stati"
    t.string "sncf_id", limit: 254
    t.string "sncf_tvs_i", limit: 254
    t.integer "sncf_is_en"
    t.string "entur_id", limit: 254
    t.integer "entur_is_e"
    t.bigint "db_id"
    t.integer "db_is_enab"
    t.string "busbud_id", limit: 254
    t.integer "busbud_is_"
    t.string "distribusi", limit: 254
    t.integer "distribu_1"
    t.bigint "flixbus_id"
    t.integer "flixbus_is"
    t.bigint "cff_id"
    t.integer "cff_is_ena"
    t.string "leoexpress", limit: 254
    t.integer "leoexpre_1"
    t.bigint "obb_id"
    t.integer "obb_is_ena"
    t.string "ouigo_id", limit: 254
    t.integer "ouigo_is_e"
    t.bigint "trenitalia"
    t.integer "trenital_1"
    t.string "trenital_2", limit: 254
    t.bigint "ntv_rtiv_i"
    t.string "ntv_id", limit: 254
    t.integer "ntv_is_ena"
    t.bigint "hkx_id"
    t.integer "hkx_is_ena"
    t.string "renfe_id", limit: 254
    t.integer "renfe_is_e"
    t.string "atoc_id", limit: 254
    t.integer "atoc_is_en"
    t.string "benerail_i", limit: 254
    t.integer "benerail_1"
    t.bigint "westbahn_i"
    t.integer "westbahn_1"
    t.integer "sncf_self_"
    t.bigint "same_as"
    t.string "info_en", limit: 254
    t.string "info_es", limit: 254
    t.string "normalised", limit: 254
    t.string "iata_airpo", limit: 254
  end

  create_table "state", primary_key: "statefp", id: { type: :string, limit: 2 }, force: :cascade do |t|
    t.serial "gid", null: false
    t.string "region", limit: 2
    t.string "division", limit: 2
    t.string "statens", limit: 8
    t.string "stusps", limit: 2, null: false
    t.string "name", limit: 100
    t.string "lsad", limit: 2
    t.string "mtfcc", limit: 5
    t.string "funcstat", limit: 1
    t.bigint "aland"
    t.bigint "awater"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.index ["gid"], name: "uidx_tiger_state_gid", unique: true
    t.index ["stusps"], name: "uidx_tiger_state_stusps", unique: true
    t.index ["the_geom"], name: "idx_tiger_state_the_geom_gist", using: :gist
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_the_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_the_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_the_geom"
  end

  create_table "tabblock", primary_key: "tabblock_id", id: { type: :string, limit: 16 }, force: :cascade do |t|
    t.serial "gid", null: false
    t.string "statefp", limit: 2
    t.string "countyfp", limit: 3
    t.string "tractce", limit: 6
    t.string "blockce", limit: 4
    t.string "name", limit: 20
    t.string "mtfcc", limit: 5
    t.string "ur", limit: 1
    t.string "uace", limit: 5
    t.string "funcstat", limit: 1
    t.float "aland"
    t.float "awater"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_geom"
  end

  create_table "tabblock20", primary_key: "geoid", id: { type: :string, limit: 15 }, force: :cascade do |t|
    t.string "statefp", limit: 2
    t.string "countyfp", limit: 3
    t.string "tractce", limit: 6
    t.string "blockce", limit: 4
    t.string "name", limit: 10
    t.string "mtfcc", limit: 5
    t.string "ur", limit: 1
    t.string "uace", limit: 5
    t.string "uatype", limit: 1
    t.string "funcstat", limit: 1
    t.float "aland"
    t.float "awater"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"multi_polygon"}
    t.float "housing"
    t.float "pop"
  end

  create_table "tract", primary_key: "tract_id", id: { type: :string, limit: 11 }, force: :cascade do |t|
    t.serial "gid", null: false
    t.string "statefp", limit: 2
    t.string "countyfp", limit: 3
    t.string "tractce", limit: 6
    t.string "name", limit: 7
    t.string "namelsad", limit: 20
    t.string "mtfcc", limit: 5
    t.string "funcstat", limit: 1
    t.float "aland"
    t.float "awater"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_geom"
  end

  create_table "train_stations", id: :serial, force: :cascade do |t|
    t.integer "trainline_id"
    t.string "name", limit: 255
    t.string "slug", limit: 63
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.integer "parent_station_id"
    t.string "country", limit: 2
    t.string "time_zone", limit: 64
    t.boolean "is_city"
    t.boolean "is_main_station"
    t.boolean "is_airport"
    t.boolean "is_suggestable"
    t.boolean "country_hint"
    t.boolean "main_station_hint"
    t.integer "same_as"
    t.text "info_en"
    t.text "info_es"
    t.string "normalised_code", limit: 40
    t.string "iata_airport_code", limit: 3
    t.index ["country"], name: "index_train_stations_on_country"
    t.index ["iata_airport_code"], name: "index_train_stations_on_iata_airport_code"
    t.index ["latitude", "longitude"], name: "index_train_stations_on_latitude_and_longitude"
    t.index ["location"], name: "index_train_stations_on_location", using: :gist
    t.index ["name"], name: "index_train_stations_on_name"
    t.index ["normalised_code"], name: "index_train_stations_on_normalised_code"
    t.index ["time_zone"], name: "index_train_stations_on_time_zone"
  end

  create_table "zcta5", primary_key: ["zcta5ce", "statefp"], force: :cascade do |t|
    t.serial "gid", null: false
    t.string "statefp", limit: 2, null: false
    t.string "zcta5ce", limit: 5, null: false
    t.string "classfp", limit: 2
    t.string "mtfcc", limit: 5
    t.string "funcstat", limit: 1
    t.float "aland"
    t.float "awater"
    t.string "intptlat", limit: 11
    t.string "intptlon", limit: 12
    t.string "partflg", limit: 1
    t.geometry "the_geom", limit: {:srid=>4269, :type=>"line_string"}
    t.index ["gid"], name: "uidx_tiger_zcta5_gid", unique: true
    t.check_constraint "geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL", name: "enforce_geotype_the_geom"
    t.check_constraint "st_ndims(the_geom) = 2", name: "enforce_dims_the_geom"
    t.check_constraint "st_srid(the_geom) = 4269", name: "enforce_srid_the_geom"
  end

end
