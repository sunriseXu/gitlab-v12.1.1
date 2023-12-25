/* eslint-disable prefer-arrow-callback, one-var, no-var, object-shorthand, no-shadow, no-unused-vars, no-else-return, func-names */

import $ from 'jquery';
import '~/gl_dropdown';

function WeightSelect(els, options = {}) {
  const $els = $(els || '.js-weight-select');

  $els.each(function(i, dropdown) {
    var $block,
      $dropdown,
      $loading,
      $selectbox,
      $sidebarCollapsedValue,
      $value,
      abilityName,
      updateUrl,
      updateWeight;
    $dropdown = $(dropdown);
    updateUrl = $dropdown.data('issueUpdate');
    $selectbox = $dropdown.closest('.selectbox');
    $block = $selectbox.closest('.block');
    $sidebarCollapsedValue = $block.find('.sidebar-collapsed-icon span');
    $value = $block.find('.value');
    abilityName = $dropdown.data('abilityName');
    $loading = $block.find('.block-loading').fadeOut();
    const fieldName = options.fieldName || $dropdown.data('fieldName');
    const inputField = $dropdown.closest('.selectbox').find(`input[name='${fieldName}']`);

    if (Object.keys(options).includes('selected')) {
      inputField.val(options.selected);
    }

    return $dropdown.glDropdown({
      selectable: true,
      fieldName,
      toggleLabel: function(selected, el) {
        return $(el).data('id');
      },
      hidden: function(e) {
        $selectbox.hide();
        return $value.css('display', '');
      },
      id: function(obj, el) {
        if ($(el).data('none') == null) {
          return $(el).data('id');
        } else {
          return '';
        }
      },
      clicked: function(glDropdownEvt) {
        const { e } = glDropdownEvt;
        let selected = glDropdownEvt.selectedObj;
        const inputField = $dropdown.closest('.selectbox').find(`input[name='${fieldName}']`);

        if (options.handleClick) {
          e.preventDefault();
          selected = inputField.val();
          options.handleClick(selected);
        } else if ($dropdown.is('.js-issuable-form-weight')) {
          e.preventDefault();
        }
      },
    });
  });
}

export default WeightSelect;
