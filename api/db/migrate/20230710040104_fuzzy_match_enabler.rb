# frozen_string_literal: true

class FuzzyMatchEnabler < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'fuzzystrmatch'
  end
end
