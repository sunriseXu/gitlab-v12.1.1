import $ from 'jquery';
import axios from '~/lib/utils/axios_utils';
import AccessorUtilities from '~/lib/utils/accessor';
import Flash from '~/flash';
import CreateItemDropdown from '~/create_item_dropdown';
import AccessDropdown from 'ee/projects/settings/access_dropdown';
import { ACCESS_LEVELS, LEVEL_TYPES } from './constants';
import { __ } from '~/locale';

export default class ProtectedBranchCreate {
  constructor() {
    this.$form = $('.js-new-protected-branch');
    this.isLocalStorageAvailable = AccessorUtilities.isLocalStorageAccessSafe();
    this.currentProjectUserDefaults = {};
    this.buildDropdowns();
    this.$branchInput = this.$form.find('input[name="protected_branch[name]"]');
    this.bindEvents();
  }

  bindEvents() {
    this.$form.on('submit', this.onFormSubmit.bind(this));
  }

  buildDropdowns() {
    const $allowedToMergeDropdown = this.$form.find('.js-allowed-to-merge');
    const $allowedToPushDropdown = this.$form.find('.js-allowed-to-push');

    // Cache callback
    this.onSelectCallback = this.onSelect.bind(this);

    // Allowed to Merge dropdown
    this[`${ACCESS_LEVELS.MERGE}_dropdown`] = new AccessDropdown({
      $dropdown: $allowedToMergeDropdown,
      accessLevelsData: gon.merge_access_levels,
      onSelect: this.onSelectCallback,
      accessLevel: ACCESS_LEVELS.MERGE,
    });

    // Allowed to Push dropdown
    this[`${ACCESS_LEVELS.PUSH}_dropdown`] = new AccessDropdown({
      $dropdown: $allowedToPushDropdown,
      accessLevelsData: gon.push_access_levels,
      onSelect: this.onSelectCallback,
      accessLevel: ACCESS_LEVELS.PUSH,
    });

    this.createItemDropdown = new CreateItemDropdown({
      $dropdown: this.$form.find('.js-protected-branch-select'),
      defaultToggleLabel: __('Protected Branch'),
      fieldName: 'protected_branch[name]',
      onSelect: this.onSelectCallback,
      getData: ProtectedBranchCreate.getProtectedBranches,
    });
  }

  // Enable submit button after selecting an option
  onSelect() {
    const $allowedToMerge = this[`${ACCESS_LEVELS.MERGE}_dropdown`].getSelectedItems();
    const $allowedToPush = this[`${ACCESS_LEVELS.PUSH}_dropdown`].getSelectedItems();
    const toggle = !(
      this.$form.find('input[name="protected_branch[name]"]').val() &&
      $allowedToMerge.length &&
      $allowedToPush.length
    );

    this.$form.find('input[type="submit"]').attr('disabled', toggle);
  }

  static getProtectedBranches(term, callback) {
    callback(gon.open_branches);
  }

  getFormData() {
    const formData = {
      authenticity_token: this.$form.find('input[name="authenticity_token"]').val(),
      protected_branch: {
        name: this.$form.find('input[name="protected_branch[name]"]').val(),
      },
    };

    Object.keys(ACCESS_LEVELS).forEach(level => {
      const accessLevel = ACCESS_LEVELS[level];
      const selectedItems = this[`${accessLevel}_dropdown`].getSelectedItems();
      const levelAttributes = [];

      selectedItems.forEach(item => {
        if (item.type === LEVEL_TYPES.USER) {
          levelAttributes.push({
            user_id: item.user_id,
          });
        } else if (item.type === LEVEL_TYPES.ROLE) {
          levelAttributes.push({
            access_level: item.access_level,
          });
        } else if (item.type === LEVEL_TYPES.GROUP) {
          levelAttributes.push({
            group_id: item.group_id,
          });
        }
      });

      formData.protected_branch[`${accessLevel}_attributes`] = levelAttributes;
    });

    return formData;
  }

  onFormSubmit(e) {
    e.preventDefault();

    axios[this.$form.attr('method')](this.$form.attr('action'), this.getFormData())
      .then(() => {
        window.location.reload();
      })
      .catch(() => Flash(__('Failed to protect the branch')));
  }
}
