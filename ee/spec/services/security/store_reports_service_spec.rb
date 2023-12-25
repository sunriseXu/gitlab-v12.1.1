# frozen_string_literal: true

require 'spec_helper'

describe Security::StoreReportsService, '#execute' do
  let(:pipeline) { create(:ci_pipeline) }

  subject { described_class.new(pipeline).execute }

  context 'when there are reports' do
    before do
      stub_licensed_features(sast: true, dependency_scanning: true, container_scanning: true)
      create(:ee_ci_build, :sast, pipeline: pipeline)
      create(:ee_ci_build, :dependency_scanning, pipeline: pipeline)
      create(:ee_ci_build, :container_scanning, pipeline: pipeline)
    end

    it 'initializes and execute a StoreReportService for each report' do
      expect(Security::StoreReportService).to receive(:new)
        .exactly(3).times.with(pipeline, instance_of(::Gitlab::Ci::Reports::Security::Report))
        .and_wrap_original do |method, *original_args|
          method.call(*original_args).tap do |store_service|
            expect(store_service).to receive(:execute).once.and_call_original
          end
        end

      subject
    end

    context 'when StoreReportService returns an error for a report' do
      let(:reports) { Gitlab::Ci::Reports::Security::Reports.new(pipeline.sha) }
      let(:sast_report) { reports.get_report('sast') }
      let(:dast_report) { reports.get_report('dast') }
      let(:success) { { status: :success } }
      let(:error) { { status: :error, message: "something went wrong" } }

      before do
        allow(pipeline).to receive(:security_reports).and_return(reports)
      end

      it 'returns the errors after having processed all reports' do
        expect_next_instance_of(Security::StoreReportService, pipeline, sast_report) do |store_service|
          expect(store_service).to receive(:execute).and_return(error)
        end
        expect_next_instance_of(Security::StoreReportService, pipeline, dast_report) do |store_service|
          expect(store_service).to receive(:execute).and_return(success)
        end

        is_expected.to eq(error)
      end
    end
  end
end
