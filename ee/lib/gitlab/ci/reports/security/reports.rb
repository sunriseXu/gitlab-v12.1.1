# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Reports
          attr_reader :reports, :commit_sha

          def initialize(commit_sha)
            @reports = {}
            @commit_sha = commit_sha
          end

          def get_report(report_type)
            reports[report_type] ||= Report.new(report_type, commit_sha)
          end
        end
      end
    end
  end
end
