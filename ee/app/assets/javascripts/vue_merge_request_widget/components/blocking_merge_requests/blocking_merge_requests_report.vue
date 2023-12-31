<script>
import ReportSection from '~/reports/components/report_section.vue';
import { componentNames } from 'ee/reports/components/issue_body';
import { status as reportStatus } from '~/reports/constants';
import { n__ } from '~/locale';

export default {
  name: 'BlockingMergeRequestsReport',
  components: { ReportSection },
  props: {
    mr: {
      type: Object,
      required: true,
    },
  },
  computed: {
    blockingMergeRequests() {
      return this.mr.blockingMergeRequests || {};
    },
    visibleMergeRequests() {
      return this.blockingMergeRequests.visible_merge_requests || {};
    },
    shouldRenderBlockingMergeRequests() {
      return this.blockingMergeRequests.total_count > 0;
    },
    openBlockingMergeRequests() {
      return this.visibleMergeRequests.opened || [];
    },
    closedBlockingMergeRequests() {
      return this.visibleMergeRequests.closed || [];
    },
    mergedBlockingMergeRequests() {
      return this.visibleMergeRequests.merged || [];
    },
    unmergedBlockingMergeRequests() {
      return Object.keys(this.visibleMergeRequests)
        .filter(state => state !== 'merged')
        .reduce(
          (unmergedBlockingMRs, state) =>
            state === 'closed'
              ? [...this.visibleMergeRequests[state], ...unmergedBlockingMRs]
              : [...unmergedBlockingMRs, ...this.visibleMergeRequests[state]],
          [],
        );
    },
    unresolvedIssues() {
      return this.blockingMergeRequests.hidden_count > 0
        ? [
            { hiddenCount: this.blockingMergeRequests.hidden_count },
            ...this.unmergedBlockingMergeRequests,
          ]
        : this.unmergedBlockingMergeRequests;
    },
    isBlocked() {
      return (
        this.blockingMergeRequests.hidden_count > 0 || this.unmergedBlockingMergeRequests.length > 0
      );
    },
    closedCount() {
      return this.closedBlockingMergeRequests.length;
    },
    unmergedCount() {
      return this.unmergedBlockingMergeRequests.length + this.blockingMergeRequests.hidden_count;
    },
    blockedByText() {
      if (this.closedCount > 0 && this.closedCount === this.unmergedCount) {
        return n__(
          'Blocked by <strong>%d closed</strong> merge request.',
          'Blocked by <strong>%d closed</strong> merge requests.',
          this.closedCount,
        );
      }

      const mainText = n__(
        'Blocked by %d merge request',
        'Blocked by %d merge requests',
        this.unmergedCount,
      );

      return this.closedCount > 0
        ? `${mainText} <strong>${n__('(%d closed)', '(%d closed)', this.closedCount)}</strong>`
        : mainText;
    },
    status() {
      return this.isBlocked ? reportStatus.ERROR : reportStatus.SUCCESS;
    },
  },
  componentNames,
};
</script>

<template>
  <report-section
    v-if="shouldRenderBlockingMergeRequests"
    class="mr-widget-border-top mr-report blocking-mrs-report"
    :status="status"
    :has-issues="true"
    :unresolved-issues="unresolvedIssues"
    :resolved-issues="mergedBlockingMergeRequests"
    :component="$options.componentNames.BlockingMergeRequestsBody"
    :show-report-section-status-icon="false"
    issues-ul-element-class="content-list"
    issues-list-container-class="p-0"
    issue-item-class="p-0"
  >
    <template v-slot:success>
      {{ __('No blocking merge requests ') }}
      <span class="text-secondary">
        {{
          sprintf(__('(%{mrCount} merged)'), {
            mrCount: blockingMergeRequests.total_count - unmergedBlockingMergeRequests.length,
          })
        }}
      </span>
    </template>
    <template v-slot:error>
      <span v-html="blockedByText"></span>
    </template>
  </report-section>
</template>
