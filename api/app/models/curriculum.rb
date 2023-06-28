# frozen_string_literal: true

class Curriculum
  include ActiveModel::Model

  def initialize
    downloader = if ENV['AWS_ASSUME_ROLE'].present?
                   Aws::AssumeRoleCredentials.new(
                     client: Aws::STS::Client.new,
                     role_arn: Rails.configuration.aws[:assume_role],
                     role_session_name: Rails.configuration.aws[:session_name],
                   )
                 else
                   Aws::ECSCredentials.new(retries: 3)
                 end
    @s3 = Aws::S3::Client.new(credentials: downloader)
  end

  def find(sensitive: false)
    path = Rails.configuration.curriculum
    if !File.exist?(path) || File.mtime(path) < 1.day.ago
      File.open(Rails.configuration.curriculum, 'wb') do |file|
        @s3.get_object(
          {
            bucket: Rails.configuration.aws[:s3_bucket],
            key: Rails.configuration.aws[:s3_object],
          },
          target: file,
        )
        file.close
      end
    else
      Rails.logger.debug 'Using cached file!'
    end

    cv = YAML.load_file(path, safe: true)
    unless sensitive
      cv.delete('phone')
      cv['social'] = cv['social'].reject { |contact| contact['sensitive'] }
    end
    return cv
  end
end
