# frozen_string_literal: true

require 'spec_helper'

describe JiraConnect::EventsController do
  context 'feature disabled' do
    before do
      stub_feature_flags(jira_connect_app: false)
    end

    describe '#installed' do
      it 'returns 404' do
        post :installed

        expect(response).to have_gitlab_http_status(404)
      end
    end

    describe '#uninstalled' do
      it 'returns 404' do
        post :uninstalled

        expect(response).to have_gitlab_http_status(404)
      end
    end
  end

  context 'feature enabled' do
    before do
      stub_feature_flags(jira_connect_app: true)
    end

    describe '#installed' do
      subject do
        post :installed, params: {
          clientKey: '1234',
          sharedSecret: 'secret',
          baseUrl: 'https://test.atlassian.net'
        }
      end

      it 'saves the jira installation data' do
        expect { subject }.to change { JiraConnectInstallation.count }.by(1)
      end

      it 'saves the correct values' do
        subject

        installation = JiraConnectInstallation.find_by_client_key('1234')

        expect(installation.shared_secret).to eq('secret')
        expect(installation.base_url).to eq('https://test.atlassian.net')
      end

      context 'client key already exists' do
        it 'returns 422' do
          create(:jira_connect_installation, client_key: '1234')

          subject

          expect(response).to have_gitlab_http_status(422)
        end
      end
    end

    describe '#uninstalled' do
      let!(:installation) { create(:jira_connect_installation) }
      let(:qsh) { Atlassian::Jwt.create_query_string_hash('POST', '/events/uninstalled') }

      before do
        request.headers['Authorization'] = "JWT #{auth_token}"
      end

      subject { post :uninstalled }

      context 'when JWT is invalid' do
        let(:auth_token) { 'invalid_token' }

        it 'returns 403' do
          subject

          expect(response).to have_gitlab_http_status(403)
        end

        it 'does not delete the installation' do
          expect { subject }.not_to change { JiraConnectInstallation.count }
        end
      end

      context 'when JWT is valid' do
        let(:auth_token) do
          Atlassian::Jwt.encode({ iss: installation.client_key, qsh: qsh }, installation.shared_secret)
        end

        it 'deletes the installation' do
          expect { subject }.to change { JiraConnectInstallation.count }.by(-1)
        end
      end
    end
  end
end
