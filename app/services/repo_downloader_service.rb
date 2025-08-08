# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "faraday/follow_redirects"
require "zip"
require "securerandom"
require "fileutils"

class RepoDownloaderService
  attr_reader :download_folder_hash

  def initialize
    @download_folder_hash = SecureRandom.hex(16)
  end

  def download_and_extract(repo_download_url)
    temp_dir = create_temp_directory
    zip_file_path = download_zip_file(repo_download_url, temp_dir)
    extract_zip_file(zip_file_path, temp_dir)
    File.delete(zip_file_path) if File.exist?(zip_file_path)

    temp_dir
  rescue => e
    cleanup_temp_directory(temp_dir) if temp_dir && Dir.exist?(temp_dir)
    raise e
  end

  def cleanup_temp_directory(temp_dir = nil)
    dir_to_cleanup = temp_dir || File.join("/tmp", download_folder_hash)
    FileUtils.rm_rf(dir_to_cleanup) if Dir.exist?(dir_to_cleanup)
  end

  private

  def create_temp_directory
    temp_dir = File.join("/tmp", download_folder_hash)
    FileUtils.mkdir_p(temp_dir)
    temp_dir
  end

  def download_zip_file(repo_download_url, temp_dir)
    zip_file_path = File.join(temp_dir, "repo.zip")

    conn = Faraday.new do |f|
      f.request :retry, max: 2, interval: 0.05
      f.response :follow_redirects
      f.adapter Faraday.default_adapter
    end

    response = conn.get(repo_download_url) do |req|
      req.options.timeout = 300 # 5 minutes timeout
    end

    raise "Failed to download repository: HTTP #{response.status}" unless response.success?

    File.open(zip_file_path, "wb") do |file|
      file.write(response.body)
    end

    zip_file_path
  end

  def extract_zip_file(zip_file_path, temp_dir)
    Zip::File.open(zip_file_path) do |zip_file|
      zip_file.each do |entry|
        entry_path = File.join(temp_dir, entry.name)
        FileUtils.mkdir_p(File.dirname(entry_path))
        entry.extract(entry_path) unless File.exist?(entry_path)
      end
    end
  end
end
