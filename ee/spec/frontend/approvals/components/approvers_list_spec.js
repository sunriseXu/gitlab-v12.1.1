import { shallowMount, createLocalVue } from '@vue/test-utils';
import ApproversListEmpty from 'ee/approvals/components/approvers_list_empty.vue';
import ApproversListItem from 'ee/approvals/components/approvers_list_item.vue';
import ApproversList from 'ee/approvals/components/approvers_list.vue';
import { TYPE_USER, TYPE_GROUP } from 'ee/approvals/constants';

const localVue = createLocalVue();
const TEST_APPROVERS = [
  { id: 1, type: TYPE_GROUP },
  { id: 1, type: TYPE_USER },
  { id: 2, type: TYPE_USER },
];

describe('ApproversList', () => {
  let propsData;
  let wrapper;

  const factory = (options = {}) => {
    wrapper = shallowMount(localVue.extend(ApproversList), {
      ...options,
      localVue,
      propsData,
    });
  };

  beforeEach(() => {
    propsData = {};
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when empty', () => {
    beforeEach(() => {
      propsData.value = [];
    });

    it('renders empty', () => {
      factory();

      expect(wrapper.find(ApproversListEmpty).exists()).toBe(true);
      expect(wrapper.find('ul').exists()).toBe(false);
    });
  });

  describe('when not empty', () => {
    beforeEach(() => {
      propsData.value = TEST_APPROVERS;
    });

    it('renders items', () => {
      factory();

      const items = wrapper.findAll(ApproversListItem).wrappers.map(item => item.props('approver'));

      expect(items).toEqual(TEST_APPROVERS);
    });

    TEST_APPROVERS.forEach((approver, idx) => {
      it(`when remove (${idx}), emits new input`, () => {
        factory();

        const item = wrapper.findAll(ApproversListItem).at(idx);
        item.vm.$emit('remove', approver);

        const expected = TEST_APPROVERS.filter((x, i) => i !== idx);

        expect(wrapper.emittedByOrder()).toEqual([{ name: 'input', args: [expected] }]);
      });
    });
  });
});
