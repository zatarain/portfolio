# frozen_string_literal: true

require 'aws-sdk-s3'
require 'safe_yaml'

class PagesController < ApplicationController
  def home
    if ENV['AWS_ASSUME_ROLE'].present?
      downloader = Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new,
        role_arn: Rails.configuration.aws[:assume_role],
        role_session_name: Rails.configuration.aws[:session_name],
      )
      s3 = Aws::S3::Client.new(credentials: downloader)
    else
      s3 = Aws::S3::Client.new
    end
    File.open(Rails.configuration.curriculum, 'wb') do |file|
      s3.get_object(
        {
          bucket: Rails.configuration.aws[:s3_bucket],
          key: Rails.configuration.aws[:s3_object],
        },
        target: file,
      )
      file.close
    end
    cv = YAML.load(File.read(Rails.configuration.curriculum), safe: true)
    render json: cv, status: :ok
  end
end
