# frozen_string_literal: true

require "spec_helper"

describe API::Services do
  set(:user) { create(:user) }

  set(:project) do
    create(:project, creator_id: user.id, namespace: user.namespace)
  end

  describe 'Slack application Service' do
    before do
      project.create_gitlab_slack_application_service

      stub_application_setting(
        slack_app_verification_token: 'token'
      )
    end

    it 'returns status 200' do
      post api('/slack/trigger'), params: { token: 'token', text: 'help' }

      expect(response).to have_gitlab_http_status(200)
      expect(json_response['response_type']).to eq("ephemeral")
    end
  end
end
