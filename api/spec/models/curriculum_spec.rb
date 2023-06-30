# frozen_string_literal: true

require 'rails_helper'

describe Curriculum, type: :model do
  let(:assume_role_credentials) { instance_double(Aws::AssumeRoleCredentials) }
  let(:ecs_credentials) { instance_double(Aws::ECSCredentials) }
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:data) do
    {
      name: 'My Test Name',
      phone: [
        '+44 07 XXX YYY ZZZ',
        '+52 1 XXX YYY ZZZZ',
      ],
      social: [
        {
          network: 'LinkedIn',
          alias: 'dummy',
          sensitive: false,
        },
        {
          network: 'Facebook',
          alias: 'dummy',
          sensitive: true,
        },
        {
          network: 'GitHub',
          alias: 'dummy',
          sensitive: false,
        },
      ],
      statement: 'This is a dummy statement paragraph',
      'work-experience': [
        {
          role: 'Dummy Role',
          type: 'full-time',
          company: 'Dummy Company',
          city: 'Dummy City',
          country: 'Dummy Country',
        },
        {
          role: 'Dummy Role Inter',
          type: 'part-time',
          company: 'Dummy Company',
          city: 'Another City',
          country: 'Same Country',
        },
      ],
      awards: [
        'dummy award one',
        'dummy award two',
      ],
    }.deep_stringify_keys
  end

  describe 'initialize' do
    context 'when AWS_ASSUME_ROLE is set' do
      let(:dummy_role) { 'arn:aws:iam::0123456789:role/DummyRole' }
      let(:dummy_session) { 'dummy-session-name' }
      let(:sts_client) { instance_double(Aws::STS::Client) }

      before do
        ENV['AWS_ASSUME_ROLE'] = dummy_role
        allow(Rails.configuration).to receive(:aws).and_return({
          assume_role: dummy_role,
          session_name: dummy_session,
        })
        allow(Aws::STS::Client).to receive(:new).and_return(sts_client)
        allow(Aws::AssumeRoleCredentials).to receive(:new).and_return(assume_role_credentials)
        allow(Aws::S3::Client).to receive(:new)
      end

      it 'uses Assume Role Credentials' do
        described_class.new
        expect(Aws::AssumeRoleCredentials).to have_received(:new).with(
          client: sts_client,
          role_arn: dummy_role,
          role_session_name: dummy_session,
        )
        expect(Aws::S3::Client).to have_received(:new).with(credentials: assume_role_credentials)
      end
    end

    context 'when AWS_ASSUME_ROLE is NOT set' do
      before do
        ENV['AWS_ASSUME_ROLE'] = nil
        allow(Aws::ECSCredentials).to receive(:new).and_return(ecs_credentials)
        allow(Aws::S3::Client).to receive(:new)
      end

      it 'uses ECS Credentials' do
        described_class.new
        expect(Aws::ECSCredentials).to have_received(:new).with(retries: 3)
        expect(Aws::S3::Client).to have_received(:new).with(credentials: ecs_credentials)
      end
    end
  end

  describe 'download' do
    before do
      ENV['AWS_ASSUME_ROLE'] = nil
      allow(Rails.configuration).to receive(:curriculum).and_return('db/dummy.yml')
      allow(Rails.configuration).to receive(:aws).and_return({
        s3_bucket: 'test-cv',
        s3_object: 'dummy.yml',
      })
      allow(Aws::ECSCredentials).to receive(:new).and_return(ecs_credentials)
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(YAML).to receive(:load_file).with('db/dummy.yml', safe: true).and_return(data)
    end

    context 'when file does NOT exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(s3_client).to receive(:get_object)
      end

      it 'downloads the file from S3' do
        curriculum = described_class.new
        cv = curriculum.download
        expect(File).to have_received(:exist?)
        expect(s3_client).to have_received(:get_object)
          .with(bucket: 'test-cv', key: 'dummy.yml', response_target: 'db/dummy.yml')
        expect(cv).to be(data)
      end
    end

    context 'when file exists, but file is too old' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:mtime).and_return(2.days.ago)
        allow(s3_client).to receive(:get_object)
      end

      it 'downloads the file from S3' do
        curriculum = described_class.new
        cv = curriculum.download
        expect(File).to have_received(:exist?)
        expect(s3_client).to have_received(:get_object)
          .with(bucket: 'test-cv', key: 'dummy.yml', response_target: 'db/dummy.yml')
        expect(cv).to be(data)
      end
    end

    context 'when file exists, but file is enough recent' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:mtime).and_return(14.hours.ago)
        allow(s3_client).to receive(:get_object)
      end

      it 'does NOT download the file from S3 and uses the cached one' do
        curriculum = described_class.new
        cv = curriculum.download
        expect(File).to have_received(:exist?)
        expect(s3_client).not_to have_received(:get_object)
        expect(cv).to be(data)
      end
    end
  end

  describe 'find' do
    before do
      ENV['AWS_ASSUME_ROLE'] = nil
      allow(Rails.configuration).to receive(:curriculum).and_return('db/dummy.yml')
      allow(Aws::ECSCredentials).to receive(:new).and_return(ecs_credentials)
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:mtime).and_return(1.hour.ago)
    end

    context 'when sensitive argument is false' do
      let(:curriculum) { described_class.new }
      let(:not_sensitive) do
        [
          {
            network: 'LinkedIn',
            alias: 'dummy',
            sensitive: false,
          }.stringify_keys,
          {
            network: 'GitHub',
            alias: 'dummy',
            sensitive: false,
          }.stringify_keys,
        ]
      end

      before do
        allow(curriculum).to receive(:download).and_return(data)
      end

      it 'filters sensitive data by default' do
        cv = curriculum.find
        expect(cv).not_to have_key('phone')
        expect(cv['social']).to eq(not_sensitive)
      end

      it 'filters sensitive data when sensitive argument is explicitly passed ' do
        cv = curriculum.find(sensitive: false)
        expect(cv).not_to have_key('phone')
        expect(cv['social']).to eq(not_sensitive)
      end
    end

    context 'when sensitive argument is true' do
      let(:curriculum) { described_class.new }

      before do
        allow(curriculum).to receive(:download).and_return(data)
      end

      it 'filters sensitive data by default' do
        cv = curriculum.find(sensitive: true)
        expect(cv).to eq(data)
      end
    end
  end
end
