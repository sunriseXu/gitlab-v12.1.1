import { createLocalVue, shallowMount } from '@vue/test-utils';
import Icon from '~/vue_shared/components/icon.vue';
import ApprovedIcon from 'ee/vue_merge_request_widget/components/approvals/approved_icon.vue';

const localVue = createLocalVue();
const EXPECTED_SIZE = 16;

describe('EE MRWidget approved icon', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(localVue.extend(ApprovedIcon), {
      propsData: props,
      localVue,
      sync: false,
    });
  };

  const findIcon = () => wrapper.find(Icon);
  const findSquare = () => wrapper.find('.square');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when approved', () => {
    beforeEach(() => {
      createComponent({ isApproved: true });
    });

    it('renders icon', () => {
      const icon = findIcon();

      expect(icon.exists()).toBe(true);
      expect(icon.props()).toEqual(
        jasmine.objectContaining({
          size: EXPECTED_SIZE,
          name: 'mobile-issue-close',
        }),
      );
    });

    it('does not render square', () => {
      expect(findSquare().exists()).toBe(false);
    });
  });

  describe('when unapproved', () => {
    beforeEach(() => {
      createComponent({ isApproved: false });
    });

    it('does not render icon', () => {
      expect(findIcon().exists()).toBe(false);
    });

    it('renders square', () => {
      const square = findSquare();

      expect(square.exists()).toBe(true);
      expect(square.classes(`s${EXPECTED_SIZE}`)).toBe(true);
    });
  });
});
