<script>
import { GlButton, GlLoadingIcon, GlModal } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlLoadingIcon,
    GlModal,
  },
  props: {
    isApproving: {
      type: Boolean,
      default: false,
      required: false,
    },
    hasError: {
      type: Boolean,
      default: false,
      required: false,
    },
    modalId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      approvalPassword: '',
    };
  },
  methods: {
    approve(event) {
      event.preventDefault();
      this.$emit('approve', this.approvalPassword);
    },
    onHide() {
      this.approvalPassword = '';
      this.$emit('hide');
    },
    onShow() {
      setTimeout(() => {
        this.$refs.approvalPasswordInput.focus();
      }, 0);
    },
  },
};
</script>
<template>
  <gl-modal
    :modal-id="modalId"
    :ok-disabled="isApproving"
    :title="s__('Enter your password to approve')"
    ok-variant="success"
    modal-class="js-mr-approvals-modal"
    @ok="approve"
    @hide="onHide"
    @show="onShow"
  >
    <form @submit.prevent="approve">
      <p>
        {{
          s__(
            'mrWidget|To approve this merge request, please enter your password. This project requires all approvals to be authenticated.',
          )
        }}
      </p>
      <div class="form-group mb-0">
        <label class="mb-1" for="approvalPasswordInput">{{ s__('mrWidget|Your password') }}</label>
        <div>
          <input
            id="approvalPasswordInput"
            ref="approvalPasswordInput"
            v-model="approvalPassword"
            type="password"
            class="form-control"
            :class="{ 'is-invalid': hasError }"
            autocomplete="new-password"
            :placeholder="s__('Password')"
          />
        </div>
      </div>
      <div v-if="hasError">
        <span class="gl-field-error">{{ s__('mrWidget|Approval password is invalid.') }}</span>
      </div>
    </form>

    <template slot="modal-cancel">{{ s__('Cancel') }}</template>

    <template slot="modal-ok">
      <gl-loading-icon v-if="isApproving" inline />
      {{ s__('Approve') }}
    </template>
  </gl-modal>
</template>
