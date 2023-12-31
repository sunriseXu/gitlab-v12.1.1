import * as types from './mutation_types';
import mirror, { canConnect } from '../../../lib/mirror';

export const upload = ({ rootState, commit }) => {
  commit(types.START_LOADING);

  return mirror
    .upload(rootState)
    .then(() => {
      commit(types.SET_SUCCESS);
    })
    .catch(err => {
      commit(types.SET_ERROR, err);
    });
};

export const stop = ({ commit }) => {
  mirror.disconnect();

  commit(types.STOP);
};

export const start = ({ rootState, commit }) => {
  const { session } = rootState.terminal;
  const path = session && session.proxyWebsocketPath;
  if (!path || !canConnect(session)) {
    return Promise.reject();
  }

  commit(types.START_LOADING);

  return mirror
    .connect(path)
    .then(() => {
      commit(types.SET_SUCCESS);
    })
    .catch(err => {
      commit(types.SET_ERROR, err);
      return Promise.reject(err);
    });
};
