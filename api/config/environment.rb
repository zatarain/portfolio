# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActiveRecord::SchemaDumper.ignore_tables = [
	'addr',
	'county_lookup',
	'countysub_lookup',
	'direction_lookup',
	'featnames',
	'geocode_settings',
	'geocode_settings_default',
	'layer',
	'loader_lookuptables',
	'loader_platform',
	'loader_variables',
	'pagc_gaz',
	'pagc_lex',
	'pagc_rules',
	'place_lookup',
	'secondary_unit_lookup',
	'spatial_ref_sys',
	'state_lookup',
	'street_type_lookup',
	'topology',
	'us_gaz',
	'us_lex',
	'us_rules',
	'zip_lookup',
	'zip_lookup_all',
	'zip_lookup_base',
	'zip_state',
	'zip_state_loc',
]
