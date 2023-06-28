# frozen_string_literal: true

require 'aws-sdk-s3'
require 'safe_yaml'

class PagesController < ApplicationController
  def home
    downloader = Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: Rails.configuration.aws[:assume_role],
      role_session_name: Rails.configuration.aws[:session_name],
    )
    s3 = Aws::S3::Client.new(credentials: downloader)
    File.open(Rails.configuration.curriculum, 'wb') do |file|
      response = s3.get_object(
        {
          bucket: Rails.configuration.aws[:s3_bucket],
          key: Rails.configuration.aws[:s3_object],
        },
        target: file,
      )
      Rails.logger.debug 'File content: ', response.body
      file.close
    end
    cv = YAML.load(File.read(Rails.configuration.curriculum), safe: true)
    Rails.logger.debug 'File hash: ', cv
    render json: cv, status: :ok
  end
end
