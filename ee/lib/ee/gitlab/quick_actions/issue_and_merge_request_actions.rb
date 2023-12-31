# frozen_string_literal: true

module EE
  module Gitlab
    module QuickActions
      module IssueAndMergeRequestActions
        extend ActiveSupport::Concern
        include ::Gitlab::QuickActions::Dsl

        included do
          desc _('Change assignee(s)')
          explanation do
            _('Change assignee(s).')
          end
          params '@user1 @user2'
          types Issue, MergeRequest
          condition do
            quick_action_target.allows_multiple_assignees? &&
              quick_action_target.persisted? &&
              current_user.can?(:"admin_#{quick_action_target.to_ability_name}", project)
          end
          command :reassign do |reassign_param|
            @updates[:assignee_ids] = extract_users(reassign_param).map(&:id)
          end

          desc _('Set weight')
          explanation do |weight|
            _("Sets weight to %{weight}.") % { weight: weight } if weight
          end
          params "0, 1, 2, …"
          types Issue, MergeRequest
          condition do
            quick_action_target.supports_weight? &&
              current_user.can?(:"admin_#{quick_action_target.to_ability_name}", quick_action_target)
          end
          parse_params do |weight|
            weight.to_i if weight.to_i >= 0
          end
          command :weight do |weight|
            @updates[:weight] = weight if weight
          end

          desc _('Clear weight')
          explanation _('Clears weight.')
          types Issue, MergeRequest
          condition do
            quick_action_target.persisted? &&
              quick_action_target.supports_weight? &&
              quick_action_target.weight? &&
              current_user.can?(:"admin_#{quick_action_target.to_ability_name}", quick_action_target)
          end
          command :clear_weight do
            @updates[:weight] = nil
          end
        end
      end
    end
  end
end
