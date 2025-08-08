# frozen_string_literal: true

class GithubPullRequestHandler
  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  def handle
    action = payload["action"]

    if action == "opened" || action == "reopened"
      StartCodeReviewerService.start(payload)
    end
  end
end
