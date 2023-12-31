# frozen_string_literal: true

module Geo
  class FileRemovalWorker
    include ApplicationWorker
    include Gitlab::Geo::LogHelpers
    include GeoQueue

    def perform(file_path)
      remove_file!(file_path)
    end

    private

    def remove_file!(file_path)
      if File.file?(file_path)
        begin
          File.unlink(file_path)
        rescue => ex
          log_error("Failed to remove file", ex, file_path: file_path)
        end

        log_info("Removed file", file_path: file_path)
      else
        log_info("Tried to remove file, but it was not found", file_path: file_path)
      end
    end
  end
end
