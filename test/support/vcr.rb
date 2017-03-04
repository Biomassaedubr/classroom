# frozen_string_literal: true
require 'vcr'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'test/fixtures/cassettes'

  c.default_cassette_options = {
    serialize_with: :json,
    preserve_exact_body_bytes:  true,
    decode_compressed_response: true,
    record: ENV['TRAVIS'] ? :none : :once
  }

  # The GitHub application
  c.filter_sensitive_data('<TEST_APPLICATION_GITHUB_CLIENT_ID>') do
    ENV.fetch('GITHUB_CLIENT_ID') { 'a' * 20 }
  end

  c.filter_sensitive_data('<TEST_APPLICATION_GITHUB_CLIENT_SECRET>') do
    ENV.fetch('GITHUB_CLIENT_SECRET') { 'b' * 20 }
  end

  # Users with real credentials
  # The Teacher (GitHub User)
  c.filter_sensitive_data('<TEST_CLASSROOM_TEACHER_GITHUB_ID>') do
    ENV.fetch('TEST_CLASSROOM_TEACHER_GITHUB_ID') { 1 }
  end

  c.filter_sensitive_data('<TEST_CLASSROOM_TEACHER_GITHUB_TOKEN>') do
    ENV.fetch('TEST_CLASSROOM_TEACHER_GITHUB_TOKEN') { 'c' * 40 }
  end

  # A student (GitHub User)
  c.filter_sensitive_data('<TEST_CLASSROOM_STUDENT_GITHUB_ID>') do
    ENV.fetch('TEST_CLASSROOM_STUDENT_GITHUB_ID') { 2 }
  end

  c.filter_sensitive_data('<TEST_CLASSROOM_STUDENT_GITHUB_TOKEN>') do
    ENV.fetch('TEST_CLASSROOM_STUDENT_GITHUB_TOKEN') { 'd' * 40 }
  end

  # A GitHub Organization/Classroom that belongs to the teacher
  # listed above.
  c.filter_sensitive_data('<TEST_CLASSROOM_GITHUB_ID>') do
    ENV.fetch('TEST_CLASSROOM_GITHUB_ID') { 3 }
  end

  c.filter_sensitive_data('<TEST_CLASSROOM_GITHUB_LOGIN>') do
    ENV.fetch('TEST_CLASSROOM_GITHUB_LOGIN') { 'the-classroom' }
  end

  c.filter_sensitive_data('<WEBHOOK_SECRET>') do
    ENV.fetch('WEBHOOK_SECRET') { 'the-secret' }
  end
end

def oauth_client
  return @oauth_client if defined?(@oauth_client)
  @oauth_client = Octokit::Client.new(access_token: ENV.fetch('TEST_CLASSROOM_TEACHER_GITHUB_TOKEN'))
end
