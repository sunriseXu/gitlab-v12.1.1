require 'spec_helper'

describe Ci::RegisterJobService do
  set(:shared_runner) { create(:ci_runner, :instance) }
  let!(:project) { create :project, shared_runners_enabled: false }
  let!(:pipeline) { create :ci_empty_pipeline, project: project }
  let!(:pending_build) { create :ci_build, pipeline: pipeline }

  describe '#execute' do
    context 'checks database loadbalancing stickiness' do
      subject { described_class.new(shared_runner).execute }

      it 'result is valid if replica did caught-up' do
        allow(Gitlab::Database::LoadBalancing).to receive(:enable?)
          .and_return(true)

        expect(Gitlab::Database::LoadBalancing::Sticking).to receive(:all_caught_up?)
          .with(:runner, shared_runner.id) { true }

        expect(subject).to be_valid
      end

      it 'result is invalid if replica did not caught-up' do
        allow(Gitlab::Database::LoadBalancing).to receive(:enable?)
          .and_return(true)

        expect(Gitlab::Database::LoadBalancing::Sticking).to receive(:all_caught_up?)
          .with(:runner, shared_runner.id) { false }

        expect(subject).not_to be_valid
      end
    end

    context 'for project with shared runners when global minutes limit is set' do
      before do
        project.update(shared_runners_enabled: true)
        stub_application_setting(shared_runners_minutes: 100)
      end

      context 'allow to pick builds' do
        let(:build) { execute(shared_runner) }

        it { expect(build).to be_kind_of(Ci::Build) }
      end

      context 'when over the global quota' do
        before do
          project.namespace.create_namespace_statistics(
            shared_runners_seconds: 6001)
        end

        let(:build) { execute(shared_runner) }

        it "does not return a build" do
          expect(build).to be_nil
        end

        context 'when project is public' do
          before do
            project.update(visibility_level: Project::PUBLIC)
          end

          it "does return the build" do
            expect(build).to be_kind_of(Ci::Build)
          end
        end

        context 'when namespace limit is set to unlimited' do
          before do
            project.namespace.update(shared_runners_minutes_limit: 0)
          end

          it "does return the build" do
            expect(build).to be_kind_of(Ci::Build)
          end
        end

        context 'when namespace quota is bigger than a global one' do
          before do
            project.namespace.update(shared_runners_minutes_limit: 101)
          end

          it "does return the build" do
            expect(build).to be_kind_of(Ci::Build)
          end
        end
      end

      context 'when group is subgroup', :nested_groups do
        let!(:root_ancestor) { create(:group) }
        let!(:group) { create(:group, parent: root_ancestor) }
        let!(:project) { create :project, shared_runners_enabled: true, group: group }
        let(:build) { execute(shared_runner) }

        it "does return a build" do
          expect(build).not_to be_nil
        end

        context 'when we are over limit on subnamespace' do
          before do
            group.create_namespace_statistics(
              shared_runners_seconds: 6001)
          end

          it "limit is ignored and build is returned" do
            expect(build).not_to be_nil
          end
        end

        context 'when we are over limit on root namespace' do
          before do
            root_ancestor.create_namespace_statistics(
              shared_runners_seconds: 6001)
          end

          it "does not return a build" do
            expect(build).to be_nil
          end
        end
      end
    end

    context 'for project with shared runners when limit is set only on namespace' do
      let(:build) { execute(shared_runner) }
      let(:runners_seconds_used) { 0 }

      before do
        project.update(shared_runners_enabled: true)
        project.namespace.update(shared_runners_minutes_limit: 100)
        project.namespace.create_namespace_statistics(shared_runners_seconds: runners_seconds_used)
      end

      context 'when we are under the limit' do
        let(:runners_seconds_used) { 5000 }

        it "does return a build" do
          expect(build).not_to be_nil
        end
      end

      context 'when we are over the limit' do
        let(:runners_seconds_used) { 6001 }

        it "does not return a build" do
          expect(build).to be_nil
        end
      end

      context 'when namespace has extra minutes' do
        let(:runners_seconds_used) { 6001 }

        before do
          project.namespace.update(extra_shared_runners_minutes_limit: 5)
        end

        it "does return a build" do
          expect(build).not_to be_nil
        end
      end
    end

    def execute(runner)
      described_class.new(runner).execute.build
    end
  end
end
