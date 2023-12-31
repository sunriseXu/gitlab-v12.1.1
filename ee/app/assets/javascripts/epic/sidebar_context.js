import $ from 'jquery';
import Cookies from 'js-cookie';
import bp from '~/breakpoints';

export default class SidebarContext {
  constructor() {
    const $issuableSidebar = $('.js-issuable-update');

    $issuableSidebar
      .off('click', '.js-sidebar-dropdown-toggle')
      .on('click', '.js-sidebar-dropdown-toggle', function onClickEdit(e) {
        e.preventDefault();
        const $block = $(this).parents('.js-labels-block');
        const $selectbox = $block.find('.js-selectbox');

        // We use `:visible` to detect element visibility
        // since labels dropdown itself is handled by
        // labels_select.js which internally uses
        // $.hide() & $.show() to toggle elements
        // which requires us to use `display: none;`
        // in `labels_select/base.vue` as well.
        // see: https://gitlab.com/gitlab-org/gitlab-ee/merge_requests/4773#note_61844731
        const isVisible = Boolean($selectbox.get(0).offsetParent);
        $selectbox.toggle(!isVisible);
        $block.find('.js-value').toggle(isVisible);

        if ($selectbox.get(0).offsetParent) {
          setTimeout(() => $block.find('.js-label-select').trigger('click'), 0);
        }
      });

    window.addEventListener('beforeunload', () => {
      // collapsed_gutter cookie hides the sidebar
      const bpBreakpoint = bp.getBreakpointSize();
      if (bpBreakpoint === 'xs' || bpBreakpoint === 'sm') {
        Cookies.set('collapsed_gutter', true);
      }
    });
  }
}
