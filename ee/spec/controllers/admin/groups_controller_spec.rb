require 'spec_helper'

describe Admin::GroupsController do
  let(:admin) { create(:admin) }
  let(:group) { create(:group) }

  before do
    sign_in(admin)
  end

  describe 'POST #reset_runner_minutes' do
    subject { post :reset_runners_minutes, params: { id: group } }

    before do
      allow_any_instance_of(ClearNamespaceSharedRunnersMinutesService)
          .to receive(:execute).and_return(clear_runners_minutes_service_result)
    end

    context 'when the reset is successful' do
      let(:clear_runners_minutes_service_result) { true }

      it 'redirects to group path' do
        subject

        expect(response).to redirect_to(admin_group_path(group))
        expect(response).to set_flash[:notice]
      end
    end

    context 'when the reset is not successful' do
      let(:clear_runners_minutes_service_result) { false }

      it 'redirects back to group edit page' do
        subject

        expect(response).to render_template(:edit)
        expect(response).to set_flash.now[:error]
      end
    end
  end
end
