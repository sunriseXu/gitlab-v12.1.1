# frozen_string_literal: true

module EE
  module Clusters
    module ClustersController
      def metrics
        return render_404 unless prometheus_adapter&.can_query?

        respond_to do |format|
          format.json do
            metrics = prometheus_adapter.query(:cluster) || {}

            if metrics.any?
              render json: metrics
            else
              head :no_content
            end
          end
        end
      end

      private

      def prometheus_adapter
        return unless cluster&.application_prometheus_available?

        cluster.application_prometheus
      end
    end
  end
end
