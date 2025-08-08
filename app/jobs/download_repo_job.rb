# frozen_string_literal: true

class DownloadRepoJob < ApplicationJob
  queue_as :default

  def perform(repo_download_url)
    Rails.logger.info "Starting repository download from: #{repo_download_url}"

    downloader = RepoDownloaderService.new
    extracted_path = downloader.download_and_extract(repo_download_url)

    Rails.logger.info "Repository downloaded and extracted to: #{extracted_path}"
    Rails.logger.info "Download folder hash: #{downloader.download_folder_hash}"
  rescue => e
    Rails.logger.error "Repository download failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
