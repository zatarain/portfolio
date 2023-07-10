# frozen_string_literal: true

class PostgisEnabler < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'fuzzystrmatch'
    # enable_extension 'postgis'
    # enable_extension 'postgis_topology'
    # enable_extension 'postgis_raster'
    # enable_extension 'address_standardizer'
    # enable_extension 'address_standardizer_data_us'
    # enable_extension 'postgis_tiger_geocoder'
  end
end
