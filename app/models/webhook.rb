# frozen_string_literal: true

class Webhook
  WebhookSignatureError = Class.new(StandardError)

  def self.verify_signature(request)
    signature = request.headers["X-Hub-Signature-256"]

    raise WebhookSignatureError.new("No signature provided") unless signature.present?

    webhook_secret = Rails.application.credentials.github_webhook_secret

    payload_body = request.raw_post
    signature_to_verify = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
                                                            webhook_secret,
                                                            payload_body)}"

    unless ActiveSupport::SecurityUtils.secure_compare(signature, signature_to_verify)
      raise WebhookSignatureError.new("Invalid signature")
    end
  rescue StandardError => e
    raise WebhookSignatureError.new("Error verifying webhook signature: #{e.message}")
  end
end
