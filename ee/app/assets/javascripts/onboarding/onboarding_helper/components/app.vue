<script>
import _ from 'underscore';
import { mapState, mapActions, mapGetters } from 'vuex';
import { redirectTo } from '~/lib/utils/url_utility';
import Stats from 'ee/stats';
import OnboardingHelper from './onboarding_helper.vue';
import actionPopoverUtils from './../action_popover_utils';
import eventHub from '../event_hub';

const TRACKING_CATEGORY = 'onboarding';

export default {
  components: {
    OnboardingHelper,
  },
  props: {
    tourTitles: {
      type: Array,
      required: true,
    },
    exitTourContent: {
      type: Object,
      required: true,
    },
    goldenTanukiSvgPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      showStepContent: false,
      initialShowPopover: false,
      dismissPopover: false,
    };
  },
  computed: {
    ...mapState([
      'projectName',
      'tourKey',
      'tourData',
      'lastStepIndex',
      'helpContentIndex',
      'exitTour',
      'dismissed',
    ]),
    ...mapGetters([
      'stepIndex',
      'stepContent',
      'helpContent',
      'totalTourPartSteps',
      'percentageCompleted',
      'actionPopover',
    ]),
    helpContentData() {
      if (this.showStepContent) {
        return this.exitTour ? this.exitTourContent : this.helpContent;
      }

      return null;
    },
    completedSteps() {
      return Math.max(this.lastStepIndex, 0);
    },
  },
  mounted() {
    this.init();
  },
  methods: {
    ...mapActions([
      'setTourKey',
      'setLastStepIndex',
      'setHelpContentIndex',
      'switchTourPart',
      'setExitTour',
      'setDismissed',
    ]),
    init() {
      // ensure we show help content on consecutive pages only
      if (this.tourKey) {
        const nextStepIndex = this.lastStepIndex + 1;

        // show help content when the current was the last visited page (e.g., user navigates away and comes back to current page)
        if (this.lastStepIndex === this.stepIndex) {
          this.showStepContent = true;
          this.initActionPopover();
          // show help content when this is the upcoming page in the content list (otherwise don't show the help content)
          // and update the lastStepIndex
        } else if (nextStepIndex === this.stepIndex) {
          this.setLastStepIndex(nextStepIndex);
          this.showStepContent = true;
          this.initActionPopover();
        }
      }
    },
    initActionPopover() {
      if (this.actionPopover) {
        const { selector, text, placement } = this.actionPopover;

        // immediately show the action popover if there's not helpContent for this step
        const showPopover = !this.helpContent && !_.isUndefined(selector);

        actionPopoverUtils.renderPopover(selector, text, placement, showPopover);
      }
    },
    showActionPopover() {
      eventHub.$emit('onboardingHelper.showActionPopover');
    },
    hideActionPopover() {
      eventHub.$emit('onboardingHelper.hideActionPopover');
    },
    handleRestartStep() {
      this.showExitTourContent(false);
      Stats.trackEvent(TRACKING_CATEGORY, 'click_link', {
        label: this.getTrackingLabel(),
        property: 'restart_this_step',
      });
      eventHub.$emit('onboardingHelper.hideActionPopover');
    },
    handleSkipStep() {
      if (this.actionPopover) {
        const { selector } = this.actionPopover;
        const popoverEl = selector ? document.querySelector(selector) : null;
        if (popoverEl) {
          Stats.trackEvent(TRACKING_CATEGORY, 'click_link', {
            label: this.getTrackingLabel(),
            property: 'skip_this_step',
          });
          popoverEl.click();
        }
      }
    },
    handleClickPopoverButton(button) {
      const { showExitTourContent, exitTour, redirectPath, nextPart, dismissPopover } = button;
      const helpContentItems = this.stepContent
        ? this.stepContent.getHelpContent({ projectName: this.projectName })
        : null;

      const showNextContentItem =
        helpContentItems &&
        helpContentItems.length > 1 &&
        this.helpContentIndex < helpContentItems.length - 1;

      // display exit tour content
      if (showExitTourContent) {
        this.showExitTourContent(true);
        return;
      }

      // quit tour
      if (exitTour) {
        this.handleExitTour();
        return;
      }

      // dismiss popover if necessary
      if (_.isUndefined(dismissPopover) || dismissPopover === true) {
        this.dismissPopover = true;
      }

      // redirect to redirectPath
      if (redirectPath) {
        redirectTo(redirectPath);
        return;
      }

      // switch to the next tour part
      if (!_.isUndefined(nextPart)) {
        this.switchTourPart(nextPart);
        this.initActionPopover();
        return;
      }

      // switch to next content item
      if (showNextContentItem) {
        this.setHelpContentIndex(this.helpContentIndex + 1);
        return;
      }

      Stats.trackEvent(TRACKING_CATEGORY, 'click_button', {
        label: this.getTrackingLabel(),
        property: 'got_it',
      });

      this.showActionPopover();
    },
    handleShowExitTourContent(showExitTour) {
      Stats.trackEvent(TRACKING_CATEGORY, 'click_link', {
        label: this.getTrackingLabel(),
        property: 'exit_learn_gitlab',
      });
      this.showExitTourContent(showExitTour);
    },
    showExitTourContent(showExitTour) {
      this.dismissPopover = false;
      this.showStepContent = true;
      this.setExitTour(showExitTour);
    },
    handleExitTour() {
      this.hideActionPopover();
      this.setDismissed(true);

      // remove popover event handlers
      eventHub.$emit('onboardingHelper.destroyActionPopover');
    },
    afterAppearHook() {
      this.initialShowPopover = true;
    },
    getTrackingLabel() {
      const step = this.stepIndex + 1;
      return `part_${this.tourKey}_step_${step}`;
    },
  },
};
</script>

<template>
  <transition appear name="slide-in-fwd-bottom" @after-appear="afterAppearHook">
    <onboarding-helper
      v-if="!dismissed"
      :tour-titles="tourTitles"
      :active-tour="tourKey"
      :completed-steps="completedSteps"
      :help-content="helpContentData"
      :percentage-completed="percentageCompleted"
      :total-steps-for-tour="totalTourPartSteps"
      :initial-show="initialShowPopover"
      :dismiss-popover="dismissPopover"
      :golden-tanuki-svg-path="goldenTanukiSvgPath"
      @clickPopoverButton="handleClickPopoverButton"
      @restartStep="handleRestartStep"
      @skipStep="handleSkipStep"
      @showExitTourContent="handleShowExitTourContent"
      @exitTour="handleExitTour"
    />
  </transition>
</template>
