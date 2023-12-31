<script>
import Flash from '~/flash';
import eventHub from '~/sidebar/event_hub';
import Store from '~/sidebar/stores/sidebar_store';
import { refreshUserMergeRequestCounts } from '~/commons/nav/user_merge_requests';
import AssigneeTitle from './assignee_title.vue';
import Assignees from './assignees.vue';
import { __ } from '~/locale';

export default {
  name: 'SidebarAssignees',
  components: {
    AssigneeTitle,
    Assignees,
  },
  props: {
    mediator: {
      type: Object,
      required: true,
    },
    field: {
      type: String,
      required: true,
    },
    signedIn: {
      type: Boolean,
      required: false,
      default: false,
    },
    issuableType: {
      type: String,
      require: true,
      default: 'issue',
    },
  },
  data() {
    return {
      store: new Store(),
      loading: false,
    };
  },
  created() {
    this.removeAssignee = this.store.removeAssignee.bind(this.store);
    this.addAssignee = this.store.addAssignee.bind(this.store);
    this.removeAllAssignees = this.store.removeAllAssignees.bind(this.store);

    // Get events from glDropdown
    eventHub.$on('sidebar.removeAssignee', this.removeAssignee);
    eventHub.$on('sidebar.addAssignee', this.addAssignee);
    eventHub.$on('sidebar.removeAllAssignees', this.removeAllAssignees);
    eventHub.$on('sidebar.saveAssignees', this.saveAssignees);
  },
  beforeDestroy() {
    eventHub.$off('sidebar.removeAssignee', this.removeAssignee);
    eventHub.$off('sidebar.addAssignee', this.addAssignee);
    eventHub.$off('sidebar.removeAllAssignees', this.removeAllAssignees);
    eventHub.$off('sidebar.saveAssignees', this.saveAssignees);
  },
  methods: {
    assignSelf() {
      // Notify gl dropdown that we are now assigning to current user
      this.$el.parentElement.dispatchEvent(new Event('assignYourself'));

      this.mediator.assignYourself();
      this.saveAssignees();
    },
    saveAssignees() {
      this.loading = true;

      function setLoadingFalse() {
        this.loading = false;
      }

      this.mediator
        .saveAssignees(this.field)
        .then(setLoadingFalse.bind(this))
        .then(() => {
          refreshUserMergeRequestCounts();
        })
        .catch(() => {
          setLoadingFalse();
          return new Flash(__('Error occurred when saving assignees'));
        });
    },
  },
};
</script>

<template>
  <div>
    <assignee-title
      :number-of-assignees="store.assignees.length"
      :loading="loading || store.isFetching.assignees"
      :editable="store.editable"
      :show-toggle="!signedIn"
    />
    <assignees
      v-if="!store.isFetching.assignees"
      :root-path="store.rootPath"
      :users="store.assignees"
      :editable="store.editable"
      :issuable-type="issuableType"
      class="value"
      @assign-self="assignSelf"
    />
  </div>
</template>
