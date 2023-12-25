# frozen_string_literal: true

module Geo
  module Batch
    # Responsible for scheduling multiple jobs to mark Project Registries as requiring syncing or verification.
    #
    # This class includes an Exclusive Lease guard and only one can be executed at the same time
    # If multiple jobs are scheduled, only one will run and the others will drop forever.
    class ProjectRegistryWorker
      include ApplicationWorker
      include GeoQueue
      include ::Gitlab::Geo::LogHelpers

      BATCH_SIZE = 250
      OPERATIONS = [:resync_repositories, :recheck_repositories].freeze

      def perform(operation, range)
        case operation.to_sym
        when :resync_repositories
          resync_repositories(range)
        when :recheck_repositories
          recheck_repositories(range)
        else
          fail_invalid_operation!(operation)
        end
      end

      private

      def resync_repositories(range)
        Geo::ProjectRegistry.with_range(range[0], range[1]).each_batch(of: BATCH_SIZE) do |batch|
          batch.flag_repositories_for_resync!
        end
      end

      def recheck_repositories(range)
        Geo::ProjectRegistry.with_range(range[0], range[1]).each_batch(of: BATCH_SIZE) do |batch|
          batch.flag_repositories_for_recheck!
        end
      end

      def fail_invalid_operation!(operation)
        raise ArgumentError, "Invalid operation: '#{operation.inspect}' informed. Must be one of the following: #{OPERATIONS.map { |valid_op| "'#{valid_op}'" }.join(', ')}"
      end
    end
  end
end
