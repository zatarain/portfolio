# frozen_string_literal: true

require 'rails_helper'

describe Curriculum, type: :model do
  let(:assume_role_credentials) { instance_double(Aws::AssumeRoleCredentials) }
  let(:instagram_client) { instance_double(InstagramBasicDisplay::Client) }
  let(:ecs_credentials) { instance_double(Aws::ECSCredentials) }
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:sections) do
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

  let(:pictures) do
    [
      {
        id: '10101',
        media_url: 'https://cdn.instagram.com/dummy-01.jpg',
        caption: '#hero #homepage Dummy description 01',
      },
      {
        id: '20202',
        media_url: 'https://cdn.instagram.com/dummy-03.jpg',
        caption: 'Dummy description 02',
      },
      {
        id: '30303',
        media_url: 'https://cdn.instagram.com/dummy-03.jpg',
        caption: '#hero #homepage Dummy description 03',
      },
    ]
  end

  describe 'initialize' do
    context 'when assume_role is present' do
      let(:dummy_role) { 'arn:aws:iam::0123456789:role/DummyRole' }
      let(:dummy_session) { 'dummy-session-name' }
      let(:sts_client) { instance_double(Aws::STS::Client) }

      before do
        allow(Rails.configuration).to receive(:aws).and_return({
          assume_role: dummy_role,
          session_name: dummy_session,
        })
        allow(Aws::STS::Client).to receive(:new).and_return(sts_client)
        allow(Aws::AssumeRoleCredentials).to receive(:new).and_return(assume_role_credentials)
        allow(Aws::S3::Client).to receive(:new)
        allow(InstagramBasicDisplay::Client).to receive(:new).and_return(instagram_client)
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

    context 'when assume_role is NOT present' do
      before do
        allow(Rails.configuration).to receive(:aws).and_return({
          s3_bucket: 'test-cv',
          s3_object: 'dummy.yml',
          assume_role: nil,
        })
        allow(Aws::ECSCredentials).to receive(:new).and_return(ecs_credentials)
        allow(Aws::S3::Client).to receive(:new)
        allow(InstagramBasicDisplay::Client).to receive(:new).and_return(instagram_client)
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
      allow(Rails.configuration).to receive(:sections).and_return('db/dummy.yml')
      allow(Rails.configuration).to receive(:pictures).and_return('db/dummy.json')
      allow(Rails.configuration).to receive(:aws).and_return({
        s3_bucket: 'test-cv',
        s3_object: 'dummy.yml',
        assume_role: nil,
      })
      allow(Aws::ECSCredentials).to receive(:new).and_return(ecs_credentials)
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(InstagramBasicDisplay::Client).to receive(:new).and_return(instagram_client)
    end

    context 'when file does NOT exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(s3_client).to receive(:get_object)
      end

      it 'downloads the file from S3' do
        curriculum = described_class.new
        curriculum.download :sections

        expect(File).to have_received(:exist?)
        expect(s3_client).to have_received(:get_object)
          .with(bucket: 'test-cv', key: 'dummy.yml', response_target: 'db/dummy.yml')
      end
    end

    context 'when file exists, but file is too old' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:mtime).and_return(2.days.ago)
        response = instance_double(InstagramBasicDisplay::Response)
        json = { data: pictures }
        payload = Struct.new(*json.keys).new(*json.values)
        allow(response).to receive(:payload).and_return(payload)
        allow(instagram_client).to receive(:media_feed).and_return(response)
        allow(File).to receive(:write).and_return(true)
      end

      it 'downloads the file from Instagram' do
        curriculum = described_class.new
        curriculum.download :pictures
        expect(File).to have_received(:exist?)
        expect(instagram_client).to have_received(:media_feed)
          .with(fields: %i[caption media_url])
        expect(File).to have_received(:write)
          .with('db/dummy.json', pictures.to_json)
      end
    end

    context 'when file exists, but file is enough recent' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:mtime).and_return(14.hours.ago)
        allow(s3_client).to receive(:get_object)
        allow(Rails.logger).to receive(:info)
      end

      it 'does NOT download the file from S3 and uses the cached one instead' do
        curriculum = described_class.new
        curriculum.download :sections
        expect(File).to have_received(:exist?)
        expect(s3_client).not_to have_received(:get_object)
        expect(Rails.logger).to have_received(:info)
          .with('Using cached file: db/dummy.yml')
      end
    end

    context 'when there is an error raised from AWS SDK or Instagram' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(Rails.logger).to receive(:error)
        allow(s3_client).to receive(:get_object)
          .and_raise(StandardError.new('Unable to download the file from Internet'))
      end

      it 'logs the error message' do
        curriculum = described_class.new
        curriculum.download :sections
        expect(Rails.logger).to have_received(:error)
          .with(/Unable to download the file from Internet/)
      end
    end
  end

  describe 'find' do
    let(:hero) do
      [
        {
          id: '10101',
          media_url: 'https://cdn.instagram.com/dummy-01.jpg',
          caption: '#hero #homepage Dummy description 01',
        },
        {
          id: '30303',
          media_url: 'https://cdn.instagram.com/dummy-03.jpg',
          caption: '#hero #homepage Dummy description 03',
        },
      ]
    end

    before do
      allow(Rails.configuration).to receive(:sections).and_return('db/dummy.yml')
      allow(Rails.configuration).to receive(:pictures).and_return('db/dummy.json')
      allow(Rails.configuration).to receive(:aws).and_return({
        s3_bucket: 'test-cv',
        s3_object: 'dummy.yml',
        assume_role: nil,
      })
      allow(Rails.configuration).to receive(:instagram).and_return({
        client_id: '1010101',
        client_secret: 'dummy-instagram-secret',
        access_token: 'dummy-instagram-token',
        redirect_uri: 'https://dummy.com',
      })
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(Aws::ECSCredentials).to receive(:new).and_return(ecs_credentials)
      allow(InstagramBasicDisplay::Client).to receive(:new).and_return(instagram_client)
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:mtime).and_return(1.hour.ago)
      allow(YAML).to receive(:load_file).and_return(sections)
      allow(File).to receive(:read).and_return(pictures.to_json)
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
        allow(curriculum).to receive(:download).and_return(sections, pictures)
      end

      it 'filters sensitive data by default' do
        cv = curriculum.find
        expect(cv).not_to have_key('phone')
        expect(cv['social']).to eq(not_sensitive)
      end

      it 'filters sensitive data when sensitive argument is explicitly passed' do
        cv = curriculum.find(sensitive: false)
        expect(cv).not_to have_key('phone')
        expect(cv['social']).to eq(not_sensitive)
      end
    end

    context 'when sensitive argument is true' do
      let(:curriculum) { described_class.new }

      before do
        allow(curriculum).to receive(:download).and_return(sections, pictures)
      end

      it 'includes sensitive data in the result' do
        data = {
          **sections,
          pictures: hero,
        }.deep_stringify_keys
        cv = curriculum.find(sensitive: true)
        expect(cv).to eq(data)
      end
    end
  end
end
