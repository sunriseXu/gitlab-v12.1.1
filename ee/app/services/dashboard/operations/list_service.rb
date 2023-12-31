# frozen_string_literal: true

module Dashboard
  module Operations
    class ListService
      DashboardProject = Struct.new(:project, :last_deployment, :alert_count, :last_alert)

      def initialize(user)
        @user = user
      end

      def execute
        projects = load_projects(user)
        environments = load_environments(projects, 'production')
        last_deployments = load_last_deployments(environments)
        event_counts, last_firing_events = load_last_firing_events(environments)

        collect_data(projects, last_deployments, event_counts, last_firing_events)
      end

      private

      attr_reader :user

      def load_projects(user)
        projects = user.ops_dashboard_projects

        ProjectsService
          .new(user)
          .execute(projects)
          .to_a # 1 query
      end

      # 1 query
      def load_environments(projects, name)
        return {} if projects.empty?

        Environment
          .available
          .for_project(projects)
          .for_name(name)
          .index_by(&:project_id) # 1 query
      end

      def load_last_deployments(environments)
        return {} if environments.empty?

        Deployment
          .last_for_environment(environments.values) # 2 queries
          .index_by(&:project_id)
      end

      def load_last_firing_events(environments)
        return [0, {}] if environments.empty?

        events = PrometheusAlertEvent
          .firing
          .for_environment(environments.values)

        event_counts = events.count_by_project_id # 1 query
        last_firing_events = events.last_by_project_id.index_by(&:project_id) # 2 queries

        [event_counts, last_firing_events]
      end

      def collect_data(projects, last_deployments, event_counts, last_firing_events)
        projects.map do |project|
          last_deployment = last_deployments[project.id]
          alert_count = event_counts[project.id] || 0
          last_alert = last_firing_events[project.id]&.prometheus_alert

          DashboardProject.new(project, last_deployment, alert_count, last_alert)
        end
      end
    end
  end
end
