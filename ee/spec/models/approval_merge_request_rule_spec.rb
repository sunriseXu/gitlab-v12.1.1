# frozen_string_literal: true

require 'spec_helper'

describe ApprovalMergeRequestRule do
  let(:merge_request) { create(:merge_request) }

  subject { create(:approval_merge_request_rule, merge_request: merge_request) }

  describe 'validations' do
    it 'is valid' do
      expect(build(:approval_merge_request_rule)).to be_valid
    end

    it 'is invalid when the name is missing' do
      expect(build(:approval_merge_request_rule, name: nil)).not_to be_valid
    end

    context 'code owner rules' do
      it 'is valid' do
        expect(build(:code_owner_rule)).to be_valid
      end

      it 'is invalid when reusing the same name within the same merge request' do
        existing = create(:code_owner_rule, name: '*.rb', merge_request: merge_request)

        new = build(:code_owner_rule, merge_request: existing.merge_request, name: '*.rb')

        expect(new).not_to be_valid
        expect { new.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it 'allows a regular rule with the same name as the codeowner rule' do
        create(:code_owner_rule, name: '*.rb', merge_request: merge_request)

        new = build(:approval_merge_request_rule, name: '*.rb', merge_request: merge_request)

        expect(new).to be_valid
        expect { new.save! }.not_to raise_error
      end

      it 'validates code_owner when rule_type code_owner' do
        new = build(:code_owner_rule)
        expect(new).to be_valid

        new.code_owner = false
        expect(new).not_to be_valid
      end

      it 'validates code_owner when rule_type regular' do
        new = build(:approval_merge_request_rule)
        expect(new).to be_valid

        new.code_owner = true
        expect(new).not_to be_valid
      end
    end

    context 'report_approver rules' do
      it 'is valid' do
        expect(build(:report_approver_rule)).to be_valid
      end

      it 'validates presence of report_type' do
        rule = build(:report_approver_rule)
        expect(rule).to be_valid

        rule.report_type = nil
        expect(rule).not_to be_valid
      end
    end
  end

  context 'scopes'  do
    set(:rb_rule) { create(:code_owner_rule, name: '*.rb') }
    set(:js_rule) { create(:code_owner_rule, name: '*.js') }
    set(:css_rule) { create(:code_owner_rule, name: '*.css') }
    set(:approval_rule) { create(:approval_merge_request_rule) }

    describe '.not_matching_pattern' do
      it 'returns the correct rules' do
        expect(described_class.not_matching_pattern(['*.rb', '*.js']))
          .to contain_exactly(css_rule)
      end
    end

    describe '.matching_pattern' do
      it 'returns the correct rules' do
        expect(described_class.matching_pattern(['*.rb', '*.js']))
          .to contain_exactly(rb_rule, js_rule)
      end
    end

    describe '.code_owners' do
      it 'returns the correct rules' do
        expect(described_class.code_owner)
          .to contain_exactly(rb_rule, js_rule, css_rule)
      end
    end
  end

  describe '.find_or_create_code_owner_rule' do
    set(:merge_request) { create(:merge_request) }
    set(:existing_code_owner_rule) { create(:code_owner_rule, name: '*.rb', merge_request: merge_request) }

    it 'finds an existing rule' do
      expect(described_class.find_or_create_code_owner_rule(merge_request, '*.rb'))
        .to eq(existing_code_owner_rule)
    end

    it 'creates a new rule if it does not exist' do
      expect { described_class.find_or_create_code_owner_rule(merge_request, '*.js') }
        .to change { merge_request.approval_rules.matching_pattern('*.js').count }.by(1)
    end

    it 'finds an existing rule using deprecated code_owner column' do
      deprecated_code_owner_rule = create(:code_owner_rule, name: '*.md', merge_request: merge_request)
      deprecated_code_owner_rule.update_column(:rule_type, described_class.rule_types[:regular])

      expect(described_class.find_or_create_code_owner_rule(merge_request, '*.md'))
        .to eq(deprecated_code_owner_rule)
    end

    it 'retries when a record was created between the find and the create' do
      expect(described_class).to receive(:code_owner).and_raise(ActiveRecord::RecordNotUnique)
      allow(described_class).to receive(:code_owner).and_call_original

      expect(described_class.find_or_create_code_owner_rule(merge_request, '*.js')).not_to be_nil
    end
  end

  describe '#project' do
    it 'returns project of MergeRequest' do
      expect(subject.project).to be_present
      expect(subject.project).to eq(merge_request.project)
    end
  end

  describe '#regular' do
    it 'returns true for regular records' do
      subject = create(:approval_merge_request_rule, merge_request: merge_request)

      expect(subject.regular).to eq(true)
      expect(subject.regular?).to eq(true)
    end

    it 'returns false for code owner records' do
      subject = create(:code_owner_rule, merge_request: merge_request)

      expect(subject.regular).to eq(false)
      expect(subject.regular?).to eq(false)
    end
  end

  describe '#code_owner?' do
    it 'returns true when deprecated code_owner bool is set' do
      code_owner_rule = build(:code_owner_rule)

      expect(code_owner_rule.code_owner?).to be true

      code_owner_rule.rule_type = :regular

      expect(code_owner_rule.code_owner?).to be true
    end
  end

  describe '#approvers' do
    before do
      create(:group) do |group|
        group.add_guest(merge_request.author)
        subject.groups << group
      end
    end

    context 'when project merge_requests_author_approval is true' do
      it 'contains author' do
        merge_request.project.update(merge_requests_author_approval: true)

        expect(subject.approvers).to contain_exactly(merge_request.author)
      end
    end

    context 'when project merge_requests_author_approval is false' do
      before do
        merge_request.project.update(merge_requests_author_approval: false)
      end

      it 'does not contain author' do
        expect(subject.approvers).to be_empty
      end

      context 'when the rules users have already been loaded' do
        before do
          subject.users
          subject.group_users
        end

        it 'does not cause queries' do
          expect { subject.approvers }.not_to exceed_query_limit(0)
        end

        it 'does not contain the author' do
          expect(subject.approvers).to be_empty
        end
      end
    end
  end

  describe '#sync_approved_approvers' do
    let(:member1) { create(:user) }
    let(:member2) { create(:user) }
    let(:member3) { create(:user) }
    let!(:approval1) { create(:approval, merge_request: merge_request, user: member1) }
    let!(:approval2) { create(:approval, merge_request: merge_request, user: member2) }
    let!(:approval3) { create(:approval, merge_request: merge_request, user: member3) }

    before do
      subject.users = [member1, member2]
    end

    context 'when not merged' do
      it 'does nothing' do
        subject.sync_approved_approvers

        expect(subject.approved_approvers.reload).to be_empty
      end
    end

    context 'when merged' do
      let(:merge_request) { create(:merged_merge_request) }

      it 'records approved approvers as approved_approvers association' do
        subject.sync_approved_approvers

        expect(subject.approved_approvers.reload).to contain_exactly(member1, member2)
      end
    end
  end

  describe 'validations' do
    describe 'approvals_required' do
      subject { build(:approval_merge_request_rule, merge_request: merge_request) }

      it 'is a natual number' do
        subject.assign_attributes(approvals_required: 2)
        expect(subject).to be_valid

        subject.assign_attributes(approvals_required: 0)
        expect(subject).to be_valid

        subject.assign_attributes(approvals_required: -1)
        expect(subject).to be_invalid
      end

      context 'when project rule is present' do
        let(:project_rule) { create(:approval_project_rule, project: merge_request.project, approvals_required: 3) }

        it 'has to be greater than or equal to project rule approvals_required' do
          subject.assign_attributes(approval_project_rule: project_rule, approvals_required: 2)
          subject.valid?

          expect(subject.errors[:approvals_required]).to include("must be greater than or equal to 3")
        end
      end
    end
  end
end
