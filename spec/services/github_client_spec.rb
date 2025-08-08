# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubClient do
  let(:installation_id) { 12345 }
  let(:access_token) { 'ghs_test_token_123' }
  let(:repo) { 'owner/repo' }
  let(:pr_number) { 42 }
  let(:comment) { 'This is a test comment' }
  let(:mock_octokit_client) { instance_double(Octokit::Client) }

  before do
    # Stub the JWT generation service
    allow(Github::GenerateJwt).to receive(:installation_token)
      .with(installation_id)
      .and_return(access_token)

    # Stub the Octokit client creation
    allow(Octokit::Client).to receive(:new)
      .with(bearer_token: access_token)
      .and_return(mock_octokit_client)
  end

  describe '#initialize' do
    it 'generates an installation token and creates an Octokit client' do
      client = described_class.new(installation_id)

      expect(Github::GenerateJwt).to have_received(:installation_token).with(installation_id)
      expect(Octokit::Client).to have_received(:new).with(bearer_token: access_token)
    end
  end

  describe '#add_comment' do
    let(:client) { described_class.new(installation_id) }
    let(:expected_response) { { 'id' => 123, 'body' => comment } }

    before do
      allow(mock_octokit_client).to receive(:add_comment)
        .with(repo, pr_number, comment)
        .and_return(expected_response)
    end

    it 'calls add_comment on the Octokit client with correct parameters' do
      result = client.add_comment(repo, pr_number, comment)

      expect(mock_octokit_client).to have_received(:add_comment)
        .with(repo, pr_number, comment)
      expect(result).to eq(expected_response)
    end

    context 'when the Octokit client raises an error' do
      before do
        allow(mock_octokit_client).to receive(:add_comment)
          .and_raise(Octokit::NotFound.new)
      end

      it 'propagates the error' do
        expect { client.add_comment(repo, pr_number, comment) }
          .to raise_error(Octokit::NotFound)
      end
    end
  end
end
