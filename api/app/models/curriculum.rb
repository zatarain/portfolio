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
    cv = YAML.load(File.read(Rails.configuration.curriculum), safe: true)
    unless sensitive
      cv.delete('phone')
      cv['social'] = cv['social'].reject { |contact| contact['sensitive'] }
    end
    cv
  end
end
