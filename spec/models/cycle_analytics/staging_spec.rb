# frozen_string_literal: true

require 'spec_helper'

describe 'CycleAnalytics#staging' do
  extend CycleAnalyticsHelpers::TestGeneration

  let(:project) { create(:project, :repository) }
  let(:from_date) { 10.days.ago }
  let(:user) { create(:user, :admin) }

  subject { CycleAnalytics::ProjectLevel.new(project, options: { from: from_date }) }

  generate_cycle_analytics_spec(
    phase: :staging,
    data_fn: lambda do |context|
      issue = context.create(:issue, project: context.project)
      { issue: issue, merge_request: context.create_merge_request_closing_issue(context.user, context.project, issue) }
    end,
    start_time_conditions: [["merge request that closes issue is merged",
                             -> (context, data) do
                               context.merge_merge_requests_closing_issue(context.user, context.project, data[:issue])
                             end]],
    end_time_conditions:   [["merge request that closes issue is deployed to production",
                             -> (context, data) do
                               context.deploy_master(context.user, context.project)
                             end],
                            ["production deploy happens after merge request is merged (along with other changes)",
                             lambda do |context, data|
                               # Make other changes on master
                               sha = context.project.repository.create_file(
                                 context.user,
                                 context.generate(:branch),
                                 'content',
                                 message: 'commit message',
                                 branch_name: 'master')
                               context.project.repository.commit(sha)

                               context.deploy_master(context.user, context.project)
                             end]])

  context "when a regular merge request (that doesn't close the issue) is merged and deployed" do
    it "returns nil" do
      merge_request = create(:merge_request)
      MergeRequests::MergeService.new(project, user).execute(merge_request)
      deploy_master(user, project)

      expect(subject[:staging].median).to be_nil
    end
  end

  context "when the deployment happens to a non-production environment" do
    it "returns nil" do
      issue = create(:issue, project: project)
      merge_request = create_merge_request_closing_issue(user, project, issue)
      MergeRequests::MergeService.new(project, user).execute(merge_request)
      deploy_master(user, project, environment: 'staging')

      expect(subject[:staging].median).to be_nil
    end
  end
end
