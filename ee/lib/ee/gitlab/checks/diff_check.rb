# frozen_string_literal: true

module EE
  module Gitlab
    module Checks
      module DiffCheck
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        private

        def validate_path_locks?
          strong_memoize(:validate_path_locks) do
            project.feature_available?(:file_locks) &&
              project.any_path_locks? &&
              project.default_branch == branch_name # locks protect default branch only
          end
        end

        def push_rule_checks_commit?
          return false unless push_rule

          push_rule.file_name_regex.present? || push_rule.prevent_secrets
        end

        override :validations_for_diff
        def validations_for_diff
          super.tap do |validations|
            validations.push(path_locks_validation) if validate_path_locks?
            validations.push(file_name_validation) if push_rule_checks_commit?
          end
        end

        def path_locks_validation
          lambda do |diff|
            path = diff.new_path || diff.old_path

            lock_info = project.find_path_lock(path)

            if lock_info && lock_info.user != user_access.user
              return "The path '#{lock_info.path}' is locked by #{lock_info.user.name}"
            end
          end
        end

        def file_name_validation
          lambda do |diff|
            if (diff.renamed_file || diff.new_file) && blacklisted_regex = push_rule.filename_blacklisted?(diff.new_path)
              return unless blacklisted_regex.present?

              "File name #{diff.new_path} was blacklisted by the pattern #{blacklisted_regex}."
            end
          rescue ::PushRule::MatchError => e
            raise ::Gitlab::GitAccess::UnauthorizedError, e.message
          end
        end
      end
    end
  end
end
