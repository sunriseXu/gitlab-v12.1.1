# frozen_string_literal: true

module Epics
  class CloseService < Epics::BaseService
    def execute(epic)
      return epic unless can?(current_user, :update_epic, epic)

      close_epic(epic)
    end

    private

    def close_epic(epic)
      if epic.close
        epic.update(closed_by: current_user)
        SystemNoteService.change_status(epic, nil, current_user, epic.state)
        notification_service.close_epic(epic, current_user)
      end
    end
  end
end
