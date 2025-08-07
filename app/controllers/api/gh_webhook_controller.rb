# frozen_string_literal: true

require "github/webhook"

module Api
  class GhWebhookController < BaseController
    before_action :verify_github_webhook, only: [ :create ]

    def create
      # Handle the webhook payload
      event_type = request.headers["X-GitHub-Event"]

      case event_type
      when "ping"
        render json: { message: "pong" }
      when "push", "pull_request", "issues"
        # Process the webhook payload
        # You can add specific handling for different event types here
        render json: { message: "Received #{event_type} event" }
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
