# frozen_string_literal: true

require "jwt"
require "time"
require "openssl"

module Github
  class GenerateJwt
    def self.installation_token(installation_id)
      response = Faraday.post(
        "https://api.github.com/app/installations/#{installation_id}/access_tokens",
        "",
        {
          "Authorization" => "Bearer #{generate_jwt}",
          "Accept" => "application/vnd.github+json"
        }
      )

      JSON.parse(response.body)["token"]
    end

    def self.generate_jwt
      private_pem = File.read(ENV["PRIVATE_KEY_PATH"])
      private_key = OpenSSL::PKey::RSA.new(private_pem)
      payload = {
        # Issued at time
        iat: Time.now.to_i,
        # JWT expiration time (10 minutes maximum)
        exp: Time.now.to_i + (10 * 60),
        # GitHub App's identifier
        iss: Rails.application.credentials.github_client_id
      }

      JWT.encode(payload, private_key, "RS256")
    end
  end
end
