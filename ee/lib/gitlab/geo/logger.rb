# frozen_string_literal: true

module Gitlab
  module Geo
    class Logger < ::Gitlab::JsonLogger
      def self.file_name_noext
        'geo'
      end

      def self.build
        super.tap { |logger| logger.level = Rails.logger.level } # rubocop:disable Gitlab/RailsLogger
      end
    end
  end
end
