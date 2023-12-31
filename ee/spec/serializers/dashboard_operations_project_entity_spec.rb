# frozen_string_literal: true

require 'spec_helper'

describe DashboardOperationsProjectEntity do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:resource) { Dashboard::Operations::ListService::DashboardProject.new(project, nil, 0, nil) }
  let(:request) { double('request', current_user: user) }

  subject { described_class.new(resource, request: request).as_json }

  it 'has all required fields' do
    expect(subject).to include(:remove_path, :alert_count)
    expect(subject.first).to include(:id)
  end

  it 'does not have optional fields' do
    expect(subject).not_to include(:last_pipeline, :upstream_pipeline, :downstream_pipelines)
  end

  context 'when there is a pipeline' do
    let!(:pipeline) { create(:ci_pipeline, project: project, sha: project.commit.sha) }

    it 'has the last pipeline field' do
      expect(subject).to include(:last_pipeline)
    end

    context 'when there is an upstream status' do
      let(:bridge) { create(:ci_bridge, status: :pending) }

      before do
        create(:ci_sources_pipeline, pipeline: pipeline, source_job: bridge)
      end

      it 'has the triggered_by pipeline field' do
        expect(subject[:last_pipeline]).to include(:triggered_by)
      end
    end

    context 'when there is a downstream status' do
      let(:build) { create(:ci_build, pipeline: pipeline) }

      before do
        create(:ci_sources_pipeline, source_job: build)
      end

      it 'has the triggered pipeline field' do
        expect(subject[:last_pipeline]).to include(:triggered)
      end

      context 'when there are multiple downstream statuses' do
        before do
          create_list(:ci_sources_pipeline, 5, source_job: build)
        end

        it 'has the downstream pipeline field' do
          expect(subject[:last_pipeline]).to include(:triggered)
          expect(subject[:last_pipeline][:triggered].count).to eq(6)
        end
      end
    end

    context 'when there are both an upstream and downstream pipelines' do
      let(:build) { create(:ci_build, pipeline: pipeline) }
      let(:bridge) { create(:ci_bridge, status: :pending) }

      before do
        create(:ci_sources_pipeline, pipeline: pipeline, source_job: bridge)
        create_list(:ci_sources_pipeline, 5, source_job: build)
      end

      it 'has the upstream pipeline field' do
        expect(subject[:last_pipeline]).to include(:triggered_by)
      end

      it 'has the downstream pipeline field' do
        expect(subject[:last_pipeline]).to include(:triggered)
        expect(subject[:last_pipeline][:triggered].count).to eq(5)
      end
    end
  end
end
