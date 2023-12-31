<script>
import eventHub from '../event_hub';

import SectionMixin from '../mixins/section_mixin';

import { TIMELINE_CELL_MIN_WIDTH, EPIC_ITEM_HEIGHT } from '../constants';

import epicItem from './epic_item.vue';

export default {
  components: {
    epicItem,
  },
  mixins: [SectionMixin],
  props: {
    presetType: {
      type: String,
      required: true,
    },
    epics: {
      type: Array,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    currentGroupId: {
      type: Number,
      required: true,
    },
    shellWidth: {
      type: Number,
      required: true,
    },
    listScrollable: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      shellHeight: 0,
      emptyRowHeight: 0,
      showEmptyRow: false,
      offsetLeft: 0,
      showBottomShadow: false,
    };
  },
  computed: {
    emptyRowContainerStyles() {
      return {
        height: `${this.emptyRowHeight}px`,
      };
    },
    emptyRowCellStyles() {
      return {
        width: `${this.sectionItemWidth}px`,
      };
    },
    shadowCellStyles() {
      return {
        left: `${this.offsetLeft}px`,
      };
    },
  },
  watch: {
    shellWidth: function shellWidth() {
      // Scroll view to today indicator only when shellWidth is updated.
      this.scrollToTodayIndicator();
      // Initialize offsetLeft when shellWidth is updated
      this.offsetLeft = this.$el.parentElement.offsetLeft;
    },
  },
  mounted() {
    eventHub.$on('epicsListScrolled', this.handleEpicsListScroll);
    eventHub.$on('refreshTimeline', this.handleTimelineRefresh);
    this.$nextTick(() => {
      this.initMounted();
    });
  },
  beforeDestroy() {
    eventHub.$off('epicsListScrolled', this.handleEpicsListScroll);
    eventHub.$off('refreshTimeline', this.handleTimelineRefresh);
  },
  methods: {
    initMounted() {
      // Get available shell height based on viewport height
      this.shellHeight = window.innerHeight - this.$el.offsetTop;

      // In case there are epics present, initialize empty row
      if (this.epics.length) {
        this.initEmptyRow();
      }

      eventHub.$emit('epicsListRendered', {
        width: this.$el.clientWidth,
        height: this.shellHeight,
      });
    },
    /**
     * In case number of epics in the list are not sufficient
     * to fill in full page height, we need to show an empty row
     * at the bottom with fixed absolute height such that the
     * column rulers expand to full page height
     *
     * This method calculates absolute height for empty column in pixels
     * based on height of available list items and sets it to component
     * props.
     */
    initEmptyRow() {
      const children = this.$children;
      let approxChildrenHeight = children[0].$el.clientHeight * this.epics.length;

      // Check if approximate height is greater than shell height
      if (approxChildrenHeight < this.shellHeight) {
        // reset approximate height and recalculate actual height
        approxChildrenHeight = 0;
        children.forEach(child => {
          // accumulate children height
          // compensate for bottom border
          approxChildrenHeight += child.$el.clientHeight;
        });

        // set height and show empty row reducing horizontal scrollbar size
        this.emptyRowHeight = this.shellHeight - approxChildrenHeight;
        this.showEmptyRow = true;
      } else {
        this.showBottomShadow = true;
      }
    },
    /**
     * Scroll timeframe to the right of the timeline
     * by half the column size
     */
    scrollToTodayIndicator() {
      this.$el.parentElement.scrollBy(TIMELINE_CELL_MIN_WIDTH / 2, 0);
    },
    /**
     * Method to update list section when refreshTimeline event
     * is emitted on eventHub
     *
     * This method ensures that empty row is toggled
     * based on whether list has enough epics to make
     * list vertically scrollable.
     */
    handleTimelineRefresh({ initialRender = false }) {
      // Initialize emptyRow only once.
      if (initialRender) {
        this.initEmptyRow();
      }

      // Check if container height is less than total height of all Epic
      // items combined (AKA list is scrollable).
      const offsetHeight = this.$el.parentElement
        ? this.$el.parentElement.offsetHeight
        : this.$el.offsetHeight;
      const isListVertScrollable = offsetHeight < EPIC_ITEM_HEIGHT * (this.epics.length + 1);

      // Toggle empty row.
      this.showEmptyRow = !isListVertScrollable;
    },
    handleEpicsListScroll({ scrollTop, clientHeight, scrollHeight }) {
      this.showBottomShadow = Math.ceil(scrollTop) + clientHeight < scrollHeight;
    },
  },
};
</script>

<template>
  <div :style="sectionContainerStyles" class="epics-list-section">
    <epic-item
      v-for="(epic, index) in epics"
      :key="index"
      :preset-type="presetType"
      :epic="epic"
      :timeframe="timeframe"
      :current-group-id="currentGroupId"
      :shell-width="sectionShellWidth"
      :item-width="sectionItemWidth"
    />
    <div
      v-if="showEmptyRow"
      :style="emptyRowContainerStyles"
      class="epics-list-item epics-list-item-empty clearfix"
    >
      <span class="epic-details-cell"></span>
      <span
        v-for="(timeframeItem, index) in timeframe"
        :key="index"
        :style="emptyRowCellStyles"
        class="epic-timeline-cell"
      >
      </span>
    </div>
    <div v-if="showBottomShadow" :style="shadowCellStyles" class="scroll-bottom-shadow"></div>
  </div>
</template>
