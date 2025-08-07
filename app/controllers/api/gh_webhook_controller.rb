# frozen_string_literal: true

require "github/webhook"

module Api
  class GhWebhookController < BaseController
    before_action :verify_github_webhook, only: [ :create ]

    def create
      event_type = request.headers["X-GitHub-Event"]
      payload = JSON.parse(request.raw_post)

      case event_type
      when "ping"
        render json: { message: "pong" }
      when "pull_request"
        GithubPullRequestHandler.new(payload).handle
        render json: { message: "ok" }
      else
        render_error "Unsupported event type: #{event_type}", :bad_request
      end
    end

    private

    def verify_github_webhook
      Github::Webhook.verify_signature(request)
    rescue Webhook::WebhookSignatureError => e
      render_error e.message, :unauthorized
    end
  end
end
