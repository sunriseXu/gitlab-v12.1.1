import Vue from 'vue';
import featureFlagsTableComponent from 'ee/feature_flags/components/feature_flags_table.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { featureFlag } from '../mock_data';

describe('Feature Flag table', () => {
  let Component;
  let vm;

  beforeEach(() => {
    Component = Vue.extend(featureFlagsTableComponent);
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('Should render a table', () => {
    vm = mountComponent(Component, {
      featureFlags: [featureFlag],
      csrfToken: 'fakeToken',
    });

    expect(vm.$el.getAttribute('class')).toContain('table-holder');
  });

  it('Should render rows', () => {
    expect(vm.$el.querySelector('.gl-responsive-table-row')).not.toBeNull();
  });

  it('Should render a status column', () => {
    const status = featureFlag.active ? 'Active' : 'Inactive';

    expect(vm.$el.querySelector('.js-feature-flag-status')).not.toBeNull();
    expect(vm.$el.querySelector('.js-feature-flag-status').textContent.trim()).toEqual(status);
  });

  it('Should render a feature flag column', () => {
    expect(vm.$el.querySelector('.js-feature-flag-title')).not.toBeNull();
    expect(vm.$el.querySelector('.feature-flag-name').textContent.trim()).toEqual(featureFlag.name);
    expect(vm.$el.querySelector('.feature-flag-description').textContent.trim()).toEqual(
      featureFlag.description,
    );
  });

  it('should render a environments specs column', () => {
    const envColumn = vm.$el.querySelector('.js-feature-flag-environments');

    expect(envColumn).not.toBeNull();
    expect(envColumn.textContent.trim()).toContain(featureFlag.scopes[0].environment_scope);
    expect(envColumn.textContent.trim()).toContain(featureFlag.scopes[1].environment_scope);
  });

  it('should render a environments specs badge with inactive class', () => {
    const envColumn = vm.$el.querySelector('.js-feature-flag-environments');

    expect(envColumn.querySelector('.badge-inactive').textContent.trim()).toContain(
      featureFlag.scopes[1].environment_scope,
    );
  });

  it('should render a environments specs badge with active class', () => {
    const envColumn = vm.$el.querySelector('.js-feature-flag-environments');

    expect(envColumn.querySelector('.badge-active').textContent.trim()).toContain(
      featureFlag.scopes[0].environment_scope,
    );
  });

  it('Should render an actions column', () => {
    expect(vm.$el.querySelector('.table-action-buttons')).not.toBeNull();
    expect(vm.$el.querySelector('.js-feature-flag-delete-button')).not.toBeNull();
    expect(vm.$el.querySelector('.js-feature-flag-edit-button')).not.toBeNull();
    expect(vm.$el.querySelector('.js-feature-flag-edit-button').getAttribute('href')).toEqual(
      featureFlag.edit_path,
    );
  });
});
