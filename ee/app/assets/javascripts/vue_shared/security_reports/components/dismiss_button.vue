<script>
import { s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import LoadingButton from '~/vue_shared/components/loading_button.vue';

export default {
  name: 'DismissButton',
  components: {
    GlButton,
    Icon,
    LoadingButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    isDismissing: {
      type: Boolean,
      required: false,
      default: false,
    },
    isDismissed: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    buttonText() {
      return this.isDismissed
        ? s__('vulnerability|Undo dismiss')
        : s__('vulnerability|Dismiss vulnerability');
    },
  },
  methods: {
    handleDismissClick() {
      if (this.isDismissed) {
        this.$emit('revertDismissVulnerability');
      } else {
        this.$emit('dismissVulnerability');
      }
    },
  },
};
</script>

<template>
  <div class="btn-group" role="group">
    <loading-button
      :loading="isDismissing"
      :disabled="isDismissing"
      :label="buttonText"
      container-class="js-dismiss-btn btn btn-close"
      @click="handleDismissClick"
    />
    <gl-button
      v-if="!isDismissed"
      v-gl-tooltip.hover
      v-gl-tooltip.focus
      :title="s__('vulnerability|Add comment & dismiss')"
      variant="close"
      class="js-dismiss-with-comment "
      @click="$emit('openDismissalCommentBox')"
    >
      <icon name="comment" />
    </gl-button>
  </div>
</template>
