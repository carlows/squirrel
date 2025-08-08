# frozen_string_literal: true

class GithubPullRequestHandler
  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  def handle
    action = payload["action"]

    if action == "opened"
      CodeReviewerService.start(payload)
    end
  end
end
