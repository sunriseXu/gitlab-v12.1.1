import Vue from 'vue';
import Vuex from 'vuex';
import notesModule from '~/notes/stores/modules';
import diffsModule from '~/diffs/store/modules';
import mrPageModule from '~/mr_notes/stores/modules';
import batchCommentsModule from 'ee/batch_comments/stores/modules/batch_comments';

Vue.use(Vuex);

export const createStore = () =>
  new Vuex.Store({
    modules: {
      page: mrPageModule,
      notes: notesModule(),
      diffs: diffsModule(),
      batchComments: batchCommentsModule(),
    },
  });

export default createStore();
