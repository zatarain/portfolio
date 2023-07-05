# frozen_string_literal: true

require 'aws-sdk-s3'
require 'instagram_basic_display'
require 'safe_yaml'

class Curriculum
  include ActiveModel::Model

  def initialize
    @s3 = Aws::S3::Client.new(credentials: aws_credentials)
    @instagram = InstagramBasicDisplay::Client.new(auth_token: instagram_credentials)
  end

  def download(request)
    path = Rails.configuration.send request
    if !File.exist?(path) || File.mtime(path) < Rails.configuration.cache_duration
      send(request, path)
    else
      Rails.logger.info "Using cached file: #{path}"
    end
  rescue StandardError => exception
    Rails.logger.error "Failed to download file: #{exception.message}"
  end

  def sections(path)
    @s3.get_object(
      bucket: Rails.configuration.aws[:s3_bucket],
      key: Rails.configuration.aws[:s3_object],
      response_target: path,
    )
  end

  def pictures(path)
    response = @instagram.media_feed(fields: %i[caption media_url])
    media = response.payload.data
    File.write(path, media.to_json)
  end

  def find(sensitive: false)
    download :sections
    data = YAML.load_file(Rails.configuration.sections, safe: true)
    download :pictures
    pictures = JSON.parse(File.read(Rails.configuration.pictures))
    data['pictures'] = pictures.select { |picture| Rails.configuration.hashtag =~ picture['caption'] }

    unless sensitive
      data.delete('phone')
      data['social'] = data['social'].reject { |contact| contact['sensitive'] }
    end

    return data
  end

  private

  def aws_credentials
    if Rails.configuration.aws[:assume_role].present?
      Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new,
        role_arn: Rails.configuration.aws[:assume_role],
        role_session_name: Rails.configuration.aws[:session_name],
      )
    else
      Aws::ECSCredentials.new(retries: 3)
    end
  end

  def instagram_credentials
    Rails.configuration.instagram[:access_token]
  end
end
