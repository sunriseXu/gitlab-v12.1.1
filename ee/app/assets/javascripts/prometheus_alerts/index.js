import Vue from 'vue';
import ResetKey from './components/reset_key.vue';

export default () => {
  const el = document.querySelector('#js-settings-prometheus-alerts');

  const { authorizationKey, changeKeyUrl, notifyUrl, learnMoreUrl } = el.dataset;

  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(createElement) {
      return createElement(ResetKey, {
        props: {
          initialAuthorizationKey: authorizationKey,
          changeKeyUrl,
          notifyUrl,
          learnMoreUrl,
        },
      });
    },
  });
};
