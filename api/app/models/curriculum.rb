# frozen_string_literal: true

require 'aws-sdk-s3'
require 'safe_yaml'

class Curriculum
  include ActiveModel::Model

  def initialize
    @s3 = Aws::S3::Client.new(credentials: aws_credentials)
  end

  def download
    path = Rails.configuration.curriculum
    if !File.exist?(path) || File.mtime(path) < 1.day.ago
      file = File.open(Rails.configuration.curriculum, 'wb')
      @s3.get_object(
        {
          bucket: Rails.configuration.aws[:s3_bucket],
          key: Rails.configuration.aws[:s3_object],
        },
        target: file,
      )
      file.close
    else
      Rails.logger.debug 'Using cached file!'
    end
    YAML.load_file(path, safe: true)
  end

  def find(sensitive: false)
    cv = download
    unless sensitive
      cv.delete('phone')
      cv['social'] = cv['social'].reject { |contact| contact['sensitive'] }
    end
    return cv
  end

  private

  def aws_credentials
    if ENV['AWS_ASSUME_ROLE'].present?
      Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new,
        role_arn: Rails.configuration.aws[:assume_role],
        role_session_name: Rails.configuration.aws[:session_name],
      )
    else
      Aws::ECSCredentials.new(retries: 3)
    end
  end
end
