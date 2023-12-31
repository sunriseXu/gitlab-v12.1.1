<script>
import $ from 'jquery';
import 'select2/select2';
import _ from 'underscore';
import { __ } from '~/locale';
import Api from 'ee/api';
import { TYPE_USER, TYPE_GROUP } from '../constants';
import { renderAvatar } from '~/helpers/avatar_helper';

function addType(type) {
  return items => items.map(obj => Object.assign(obj, { type }));
}

function formatSelection(group) {
  return _.escape(group.full_name || group.name);
}

function formatResultUser(result) {
  const { name, username } = result;
  const avatar = renderAvatar(result, { sizeClass: 's40' });

  return `
    <div class="user-result">
      <div class="user-image">
        ${avatar}
      </div>
      <div class="user-info">
        <div class="user-name">${_.escape(name)}</div>
        <div class="user-username">@${_.escape(username)}</div>
      </div>
    </div>
  `;
}

function formatResultGroup(result) {
  const { full_name: fullName, full_path: fullPath } = result;
  const avatar = renderAvatar(result, { sizeClass: 's40' });

  return `
    <div class="user-result group-result">
      <div class="group-image">
        ${avatar}
      </div>
      <div class="group-info">
        <div class="group-name">${_.escape(fullName)}</div>
        <div class="group-path">${_.escape(fullPath)}</div>
      </div>
    </div>
  `;
}

function formatResult(result) {
  return result.type === TYPE_USER ? formatResultUser(result) : formatResultGroup(result);
}

export default {
  props: {
    value: {
      type: Array,
      required: false,
      default: () => [],
    },
    projectId: {
      type: String,
      required: true,
    },
    skipUserIds: {
      type: Array,
      required: false,
      default: () => [],
    },
    skipGroupIds: {
      type: Array,
      required: false,
      default: () => [],
    },
    isInvalid: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  watch: {
    value(val) {
      if (val.length === 0) {
        this.clear();
      }
    },
    isInvalid(val) {
      const $container = $(this.$refs.input).select2('container');

      if (val) {
        $container.addClass('is-invalid');
      } else {
        $container.removeClass('is-invalid');
      }
    },
  },
  mounted() {
    $(this.$refs.input)
      .select2({
        placeholder: __('Search users or groups'),
        minimumInputLength: 0,
        multiple: true,
        closeOnSelect: false,
        formatResult,
        formatSelection,
        query: _.debounce(
          ({ term, callback }) => this.fetchGroupsAndUsers(term).then(callback),
          250,
        ),
        id: ({ type, id }) => `${type}${id}`,
      })
      .on('change', e => this.onChange(e));
  },
  beforeDestroy() {
    $(this.$refs.input).select2('destroy');
  },
  methods: {
    fetchGroupsAndUsers(term) {
      const groupsAsync = this.fetchGroups(term).then(addType(TYPE_GROUP));
      const usersAsync = this.fetchUsers(term).then(addType(TYPE_USER));

      return Promise.all([groupsAsync, usersAsync])
        .then(([groups, users]) => groups.concat(users))
        .then(results => ({ results }));
    },
    fetchGroups(term) {
      // Don't includeAll when search is empty. Otherwise, the user could get a lot of garbage choices.
      // https://gitlab.com/gitlab-org/gitlab-ee/issues/11566
      const includeAll = term.trim().length > 0;

      return Api.groups(term, {
        skip_groups: this.skipGroupIds,
        all_available: includeAll,
      });
    },
    fetchUsers(term) {
      return Api.approverUsers(term, {
        skip_users: this.skipUserIds,
        project_id: this.projectId,
      });
    },
    onChange() {
      // call data instead of val to get array of objects
      const value = $(this.$refs.input).select2('data');

      this.$emit('input', value);
    },
    clear() {
      $(this.$refs.input).select2('data', []);
    },
  },
};
</script>

<template>
  <input ref="input" name="members" type="hidden" />
</template>
