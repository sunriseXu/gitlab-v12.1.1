import Vue from 'vue';
import IssuesAnalytics from 'ee/issues_analytics/components/issues_analytics.vue';
import { createStore } from 'ee/issues_analytics/stores';
import { mountComponentWithStore } from 'spec/helpers/vue_mount_component_helper';

describe('Issues Analytics component', () => {
  let vm;
  let store;
  let mountComponent;
  const Component = Vue.extend(IssuesAnalytics);
  const mockChartData = { '2017-11': 0, '2017-12': 2 };
  const mockTooltipData = {
    y: 1,
    x: 1,
    title: ['Jul 2018'],
    opacity: 1,
    body: [
      {
        lines: ['1'],
      },
    ],
    caretHeight: 1,
    caretPadding: 1,
  };

  const mockCanvas = {
    offsetLeft: 1,
    offsetTop: 1,
  };

  beforeEach(() => {
    store = createStore();
    spyOn(store, 'dispatch').and.stub();

    mountComponent = data => {
      setFixtures('<div id="mock-filter"></div>');
      const props = data || {
        endpoint: gl.TEST_HOST,
        filterBlockEl: document.querySelector('#mock-filter'),
      };
      return mountComponentWithStore(Component, { store, props });
    };

    vm = mountComponent();
    spyOn(vm, 'createChart').and.stub();
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('fetches chart data when mounted', () => {
    expect(store.dispatch).toHaveBeenCalledWith('issueAnalytics/fetchChartData', gl.TEST_HOST);
  });

  it('renders loading state when loading', done => {
    vm.$store.state.issueAnalytics.loading = true;

    vm.$nextTick(() => {
      expect(vm.$el.querySelector('.issues-analytics-loading')).not.toBe(null);
      expect(vm.$el.querySelector('.issues-analytics-chart')).toBe(null);
      done();
    });
  });

  it('renders chart when data is present', done => {
    vm.$store.state.issueAnalytics.chartData = mockChartData;

    vm.$nextTick(() => {
      expect(vm.$el.querySelector('.issues-analytics-chart')).not.toBe(null);
      done();
    });
  });

  it('renders chart tooltip with the correct details', done => {
    const [popoverTitle] = mockTooltipData.title;
    const [popoverContent] = mockTooltipData.body[0].lines;

    vm.$store.state.issueAnalytics.chartData = mockChartData;
    vm.generateCustomTooltip(mockTooltipData, mockCanvas);

    vm.$nextTick(() => {
      expect(vm.showPopover).toBe(true);
      expect(vm.popoverTitle).toEqual(popoverTitle);
      expect(vm.popoverContent).toEqual(popoverContent);
      done();
    });
  });

  it('fetches data when filters are applied', done => {
    vm.$store.state.issueAnalytics.filters = '?hello=world';

    vm.$nextTick(() => {
      expect(store.dispatch).toHaveBeenCalledTimes(2);
      expect(store.dispatch.calls.argsFor(1)).toEqual([
        'issueAnalytics/fetchChartData',
        gl.TEST_HOST,
      ]);
      done();
    });
  });

  it('renders empty state when chart data is empty', done => {
    vm.$store.state.issueAnalytics.chartData = {};

    vm.$nextTick(() => {
      expect(vm.$el.querySelector('.empty-state')).not.toBe(null);
      expect(vm.showNoDataEmptyState).toBe(true);
      done();
    });
  });

  it('renders filters empty state when filters are applied and chart data is empty', done => {
    vm.$store.state.issueAnalytics.chartData = {};
    vm.$store.state.issueAnalytics.filters = '?hello=world';

    vm.$nextTick(() => {
      expect(vm.$el.querySelector('.empty-state')).not.toBe(null);
      expect(vm.showFiltersEmptyState).toBe(true);
      done();
    });
  });
});
