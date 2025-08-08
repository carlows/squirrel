# frozen_string_literal: true

class RepoClonerService
  def initialize(clone_url)
    @clone_url = clone_url
    @output_hash = SecureRandom.hex(16)
  end

  def clone
    Git.clone(@clone_url, clone_folder)
  end

  def clone_folder
    Rails.root.join("tmp", @output_hash)
  end
end
