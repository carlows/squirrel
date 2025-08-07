# frozen_string_literal: true

require "github/generate_jwt"

class GithubClient
  def initialize(installation_id)
    token = Github::GenerateJwt.installation_token(installation_id)
    @client = Octokit::Client.new(bearer_token: token)
  end

  def add_comment(repo, pr_number, comment)
    @client.add_comment(repo, pr_number, comment)
  end
end
