require 'rails_helper'

describe 'Merge request > User sets approvers', :js do
  include ProjectForksHelper
  include FeatureApprovalHelper

  let(:user) { create(:user) }
  let(:project) { create(:project, :public, :repository, approvals_before_merge: 1) }
  let!(:config_selector) { '.js-approval-rules' }
  let!(:modal_selector) { '#mr-edit-approvals-create-modal' }

  context 'when editing an MR with a different author' do
    let(:author) { create(:user) }
    let(:merge_request) { create(:merge_request, author: author, source_project: project) }

    before do
      project.add_developer(user)
      project.add_developer(author)

      sign_in(user)
      visit edit_project_merge_request_path(project, merge_request)
    end

    it 'does not allow setting the author as an approver but allows setting the current user as an approver' do
      open_modal
      open_approver_select

      expect(find('.select2-results')).not_to have_content(author.name)
      expect(find('.select2-results')).to have_content(user.name)
    end
  end

  context 'when creating an MR from a fork' do
    let(:other_user) { create(:user) }
    let(:non_member) { create(:user) }
    let(:forked_project) { fork_project(project, user, repository: true) }

    before do
      project.add_developer(user)
      project.add_developer(other_user)

      sign_in(user)
      visit project_new_merge_request_path(forked_project, merge_request: { target_branch: 'master', source_branch: 'feature' })
    end

    it 'allows setting other users as approvers but does not allow setting the current user as an approver, and filters non members from approvers list' do
      open_modal
      open_approver_select

      expect(find('.select2-results')).to have_content(other_user.name)
      expect(find('.select2-results')).not_to have_content(non_member.name)
    end
  end

  context "Group approvers" do
    context 'when creating an MR' do
      let(:other_user) { create(:user) }

      before do
        project.add_developer(user)
        project.add_developer(other_user)

        sign_in(user)
      end

      it 'allows setting groups as approvers' do
        group = create :group
        group.add_developer(other_user)

        visit project_new_merge_request_path(project, merge_request: { target_branch: 'master', source_branch: 'feature' })

        open_modal
        open_approver_select

        expect(find('.select2-results')).not_to have_content(group.name)

        close_approver_select
        group.add_developer(user) # only display groups that user has access to
        open_approver_select

        expect(find('.select2-results')).to have_content(group.name)

        find('.select2-results .user-result', text: group.name).click
        close_approver_select
        click_button 'Add'
        click_button 'Update approvers'

        click_on("Submit merge request")
        wait_for_all_requests

        expect(page).to have_content("Requires approval.")
        expect(page).to have_selector("img[alt='#{other_user.name}']")
      end

      it 'allows delete approvers group when it is set in project' do
        approver = create :user
        project.add_developer(approver)
        group = create :group
        group.add_developer(other_user)
        group.add_developer(approver)
        create :approval_project_rule, project: project, users: [approver], groups: [group], approvals_required: 1

        visit project_new_merge_request_path(project, merge_request: { target_branch: 'master', source_branch: 'feature' })

        open_modal
        remove_approver(group.name)

        within(modal_selector) do
          expect(page).to have_css('.content-list li', count: 1)
        end

        click_button 'Update approvers'
        click_on("Submit merge request")
        wait_for_all_requests
        click_on("View eligible approvers") if page.has_button?("View eligible approvers")
        wait_for_requests

        expect(page).not_to have_selector(".js-approvers img[alt='#{other_user.name}']")
        expect(page).to have_selector(".js-approvers img[alt='#{approver.name}']")
      end
    end

    context 'when editing an MR with a different author' do
      let(:other_user) { create(:user) }
      let(:merge_request) { create(:merge_request, source_project: project) }

      before do
        project.add_developer(user)

        sign_in(user)
      end

      it 'allows setting groups as approvers' do
        group = create :group
        group.add_developer(other_user)

        visit edit_project_merge_request_path(project, merge_request)

        open_modal
        open_approver_select

        expect(find('.select2-results')).not_to have_content(group.name)

        close_approver_select
        group.add_developer(user) # only display groups that user has access to
        open_approver_select

        expect(find('.select2-results')).to have_content(group.name)

        find('.select2-results .user-result', text: group.name).click
        close_approver_select
        click_button 'Add'
        click_button 'Update approvers'

        click_on("Save changes")
        wait_for_all_requests

        expect(page).to have_content("Requires approval.")
        expect(page).to have_selector("img[alt='#{other_user.name}']")
      end

      it 'allows delete approvers group when it`s set in project' do
        approver = create :user
        project.add_developer(approver)
        group = create :group
        group.add_developer(other_user)
        group.add_developer(approver)
        create :approval_project_rule, project: project, users: [approver], groups: [group], approvals_required: 1

        visit edit_project_merge_request_path(project, merge_request)

        open_modal
        remove_approver(group.name)

        wait_for_requests
        within(modal_selector) do
          expect(page).to have_css('.content-list li', count: 1)
        end

        click_button 'Update approvers'
        click_on("Save changes")
        wait_for_all_requests

        click_on("View eligible approvers")
        wait_for_requests

        expect(page).not_to have_selector(".js-approvers img[alt='#{other_user.name}']")
        expect(page).to have_selector(".js-approvers img[alt='#{approver.name}']")
        expect(page).to have_content("Requires approval.")
      end

      it 'allows changing approvals number' do
        approvers = create_list(:user, 3)
        approvers.each { |approver| project.add_developer(approver) }
        create :approval_project_rule, project: project, users: approvers, approvals_required: 2

        visit project_merge_request_path(project, merge_request)
        wait_for_requests

        # project setting in the beginning on the show MR page
        expect(page).to have_content("Requires 2 more approvals")

        find('.merge-request').click_on 'Edit'
        open_modal

        expect(page).to have_field 'No. approvals required', exact: 2

        fill_in 'No. approvals required', with: '3'

        click_button 'Update approvers'
        click_on('Save changes')
        wait_for_all_requests

        # new MR setting on the show MR page
        expect(page).to have_content("Requires 3 more approvals")

        # new MR setting on the edit MR page
        find('.merge-request').click_on 'Edit'
        wait_for_requests

        open_modal

        expect(page).to have_field 'No. approvals required', exact: 3
      end
    end
  end
end
