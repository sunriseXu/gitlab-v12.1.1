# frozen_string_literal: true

require 'spec_helper'

describe NotificationRecipientService do
  subject(:service) { described_class }

  let(:project) { create(:project, :public) }
  let(:other_projects) { create_list(:project, 5, :public) }

  describe '#build_new_review_recipients' do
    let(:merge_request) { create(:merge_request, source_project: project, target_project: project) }
    let(:review) { create(:review, merge_request: merge_request, project: project, author: merge_request.author) }
    let(:notes) { create_list(:note_on_merge_request, 3, review: review, noteable: review.merge_request, project: review.project) }

    shared_examples 'no N+1 queries' do
      it 'avoids N+1 queries', :request_store do
        create_user

        service.build_new_review_recipients(review)

        control_count = ActiveRecord::QueryRecorder.new do
          service.build_new_review_recipients(review)
        end

        create_user

        expect { service.build_new_review_recipients(review) }.not_to exceed_query_limit(control_count)
      end
    end

    context 'when there are multiple watchers' do
      def create_user
        watcher = create(:user)
        create(:notification_setting, source: project, user: watcher, level: :watch)

        other_projects.each do |other_project|
          create(:notification_setting, source: other_project, user: watcher, level: :watch)
        end
      end

      include_examples 'no N+1 queries'
    end

    context 'when there are multiple subscribers' do
      def create_user
        subscriber = create(:user)
        merge_request.subscriptions.create(user: subscriber, project: project, subscribed: true)
      end

      include_examples 'no N+1 queries'

      context 'when the project is private' do
        before do
          project.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
        end

        include_examples 'no N+1 queries'
      end
    end
  end
end
