# frozen_string_literal: true

class Groups::BulkUpdateController < Groups::ApplicationController
  include IssuableActions

  before_action :authorize_admin_group!
  before_action :verify_group_bulk_edit_enabled!, only: [:bulk_update]

  private

  def verify_group_bulk_edit_enabled!
    render_404 unless group.feature_available?(:group_bulk_edit)
  end
end
