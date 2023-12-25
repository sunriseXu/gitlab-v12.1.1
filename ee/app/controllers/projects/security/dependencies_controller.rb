# frozen_string_literal: true

module Projects
  module Security
    class DependenciesController < Projects::ApplicationController
      before_action :ensure_dependency_list_feature_available

      def index
        respond_to do |format|
          format.json do
            ::Gitlab::UsageCounters::DependencyList.increment(project.id)

            render json: serializer.represent(dependencies, build: build)
          end
        end
      end

      private

      def build
        return unless pipeline
        return @build if @build

        @build = pipeline.builds.latest
                  .with_reports(::Ci::JobArtifact.dependency_list_reports)
                  .last
      end

      def collect_dependencies
        found_dependencies = build&.success? ? service.execute : []
        ::Gitlab::DependenciesCollection.new(found_dependencies)
      end

      def ensure_dependency_list_feature_available
        render_404 unless project.feature_available?(:dependency_list)
      end

      def dependencies
        @dependencies ||= collect_dependencies
      end

      def pipeline
        @pipeline ||= project.all_pipelines.latest_successful_for(project.default_branch)
      end

      def query_params
        params.permit(:sort, :sort_by).delete_if do |key, value|
          key == :sort_by && !value.in?(::Security::DependencyListService::SORT_BY_VALUES) ||
            key == :sort && !value.in?(::Security::DependencyListService::SORT_VALUES)
        end
      end

      def serializer
        serializer = ::DependencyListSerializer.new(project: project)
        serializer = serializer.with_pagination(request, response) if params[:page]
        serializer
      end

      def service
        ::Security::DependencyListService.new(pipeline: pipeline, params: query_params)
      end
    end
  end
end
