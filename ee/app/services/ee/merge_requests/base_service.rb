# frozen_string_literal: true

module EE
  module MergeRequests
    module BaseService
      private

      def filter_params(merge_request)
        unless current_user.can?(:update_approvers, merge_request)
          params.delete(:approvals_before_merge)
          params.delete(:approver_ids)
          params.delete(:approver_group_ids)
        end

        self.params = ApprovalRules::ParamsFilteringService.new(merge_request, current_user, params).execute

        super
      end
    end
  end
end
