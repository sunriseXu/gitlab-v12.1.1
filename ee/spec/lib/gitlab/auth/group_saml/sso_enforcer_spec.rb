# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Auth::GroupSaml::SsoEnforcer do
  let(:saml_provider) { build_stubbed(:saml_provider, enforced_sso: true) }
  let(:session) { {} }

  around do |example|
    Gitlab::Session.with_session(session) do
      example.run
    end
  end

  subject { described_class.new(saml_provider) }

  describe '#update_session' do
    it 'stores that a session is active for the given provider' do
      expect { subject.update_session }.to change { session[:active_group_sso_sign_ins] }
    end

    it 'stores the current time for later comparison' do
      Timecop.freeze do
        subject.update_session

        expect(session[:active_group_sso_sign_ins][saml_provider.id]).to eq DateTime.now
      end
    end
  end

  describe '#active_session?' do
    it 'returns false if nothing has been stored' do
      expect(subject).not_to be_active_session
    end

    it 'returns true if a sign in has been recorded' do
      subject.update_session

      expect(subject).to be_active_session
    end
  end

  describe '#allows_access?' do
    it 'allows access when saml_provider is nil' do
      subject = described_class.new(nil)

      expect(subject).not_to be_access_restricted
    end

    context 'when sso enforcement is disabled' do
      let(:saml_provider) { build_stubbed(:saml_provider, enforced_sso: false) }

      it 'allows access when sso enforcement is disabled' do
        expect(subject).not_to be_access_restricted
      end
    end

    context 'when saml_provider is disabled' do
      let(:saml_provider) { build_stubbed(:saml_provider, enforced_sso: true, enabled: false) }

      it 'allows access when saml_provider is disabled' do
        expect(subject).not_to be_access_restricted
      end
    end

    it 'allows access when the sso enforcement feature is disabled' do
      stub_feature_flags(enforced_sso: { enabled: false, thing: saml_provider.group })

      expect(subject).not_to be_access_restricted
    end

    it 'prevents access when sso enforcement active but there is no session' do
      expect(subject).to be_access_restricted
    end

    it 'allows access when sso is enforced but a saml session is active' do
      subject.update_session

      expect(subject).not_to be_access_restricted
    end
  end

  describe '.group_access_restricted?' do
    let(:root_group) { create(:group, saml_provider: create(:saml_provider, enabled: true, enforced_sso: true)) }

    context 'is restricted' do
      before do
        stub_feature_flags(enforced_sso_requires_session: { enabled: true, thing: root_group })
      end

      it 'for a group' do
        expect(described_class).to be_group_access_restricted(root_group)
      end

      it 'for a subgroup' do
        sub_group = create(:group, parent: root_group)

        expect(described_class).to be_group_access_restricted(sub_group)
      end

      it 'for a project' do
        project = create(:project, group: root_group)

        expect(described_class).to be_group_access_restricted(project)
      end
    end

    context 'is not restricted' do
      it 'for the group without configured saml_provider' do
        group = create(:group)
        stub_feature_flags(enforced_sso_requires_session: { enabled: true, thing: group })

        expect(described_class).not_to be_group_access_restricted(group)
      end

      it 'for the group without the feature flag' do
        stub_feature_flags(enforced_sso_requires_session: { enabled: false, thing: root_group })

        expect(described_class).not_to be_group_access_restricted(root_group)
      end
    end
  end
end
