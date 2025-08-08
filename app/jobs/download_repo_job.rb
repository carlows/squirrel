# frozen_string_literal: true

class DownloadRepoJob < ApplicationJob
  queue_as :default

  def perform(clone_url, head_ref, base_ref)
    Rails.logger.info "Starting repository download from: #{clone_url}"

    cloner = RepoClonerService.new(clone_url)
    cloner.clone

    Rails.logger.info "Repository cloned to: #{cloner.clone_folder}"
  rescue => e
    Rails.logger.error "Repository download failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
