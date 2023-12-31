# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module MergeRequestActions
        extend ActiveSupport::Concern
        include ::Gitlab::QuickActions::Dsl

        included do
          desc 'Approve a merge request'
          explanation 'Approve the current merge request.'
          types MergeRequest
          condition do
            quick_action_target.persisted? && quick_action_target.can_approve?(current_user) && !quick_action_target.project.require_password_to_approve?
          end
          command :approve do
            if quick_action_target.can_approve?(current_user)
              ::MergeRequests::ApprovalService.new(quick_action_target.project, current_user).execute(quick_action_target)
            end
          end
        end
      end
    end
  end
end
