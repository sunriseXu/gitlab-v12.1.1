# frozen_string_literal: true

require 'spec_helper'

describe Groups::ScimOauthController do
  let(:saml_provider) { create(:saml_provider, group: group) }
  let(:group) { create(:group, :private, parent_id: nil) }
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  def stub_saml_config(enabled:)
    providers = enabled ? %i(group_saml) : []
    allow(Devise).to receive(:omniauth_providers).and_return(providers)
  end

  context 'when the feature is enabled' do
    before do
      stub_saml_config(enabled: true)
      stub_licensed_features(group_saml: true)
      stub_feature_flags(group_scim: true)
    end

    describe 'GET #show' do
      subject { get :show, params: { group_id: group }, format: :json }

      before do
        group.add_owner(user)
      end

      context 'without token' do
        it 'shows an empty response' do
          subject

          expect(json_response).to eq({})
        end
      end

      context 'with token' do
        let!(:scim_token) { create(:scim_oauth_access_token, group: group) }

        it 'shows the token' do
          subject

          expect(json_response['scim_token']).to eq(scim_token.token)
        end

        it 'shows the url' do
          subject

          expect(json_response['scim_api_url']).not_to be_empty
        end
      end
    end

    describe 'POST #create' do
      subject { post :create, params: { group_id: group }, format: :json }

      before do
        group.add_owner(user)
      end

      context 'without token' do
        it 'creates a new SCIM token record' do
          expect { subject }.to change { ScimOauthAccessToken.count }.by(1)
        end

        context 'json' do
          before do
            subject
          end

          it 'shows the token' do
            expect(json_response['scim_token']).not_to be_empty
          end

          it 'shows the url' do
            expect(json_response['scim_api_url']).to eq("http://localhost/api/scim/v2/groups/#{group.full_path}")
          end
        end
      end

      context 'with token' do
        let!(:scim_token) { create(:scim_oauth_access_token, group: group) }

        it 'does not create a new SCIM token record' do
          expect { subject }.not_to change { ScimOauthAccessToken.count }
        end

        it 'updates the token' do
          expect { subject }.to change { scim_token.reload.token }
        end

        context 'json' do
          before do
            subject
          end

          it 'shows the token' do
            expect(json_response['scim_token']).to eq(scim_token.reload.token)
          end

          it 'shows the url' do
            expect(json_response['scim_api_url']).not_to be_empty
          end
        end
      end
    end
  end
end
