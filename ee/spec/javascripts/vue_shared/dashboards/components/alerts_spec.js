import { shallowMount, createLocalVue } from '@vue/test-utils';
import Alerts from 'ee/vue_shared/dashboards/components/alerts.vue';

const localVue = createLocalVue();

describe('alerts component', () => {
  const AlertsComponent = localVue.extend(Alerts);
  let wrapper;

  const mount = (propsData = {}) => shallowMount(AlertsComponent, { propsData, sync: false });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders multiple alert count when multiple alerts are present', () => {
    wrapper = mount({
      count: 2,
    });

    expect(wrapper.element.querySelector('.js-alert-count').innerText.trim()).toBe('2 Alerts');
  });

  it('renders count for one alert when there is one alert', () => {
    wrapper = mount({
      count: 1,
    });

    expect(wrapper.element.querySelector('.js-alert-count').innerText.trim()).toBe('1 Alert');
  });

  describe('wrapped components', () => {
    describe('icon', () => {
      it('renders warning', () => {
        wrapper = mount({
          count: 1,
        });

        expect(wrapper.element.querySelector('.js-dashboard-alerts-icon')).not.toBe(null);
      });
    });
  });
});
