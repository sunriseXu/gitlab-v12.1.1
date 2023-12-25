import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import actions, {
  setHeadBlobPath,
  setBaseBlobPath,
  setVulnerabilityFeedbackPath,
  setVulnerabilityFeedbackHelpPath,
  setPipelineId,
  setCanCreateIssuePermission,
  setCanCreateFeedbackPermission,
  setSastHeadPath,
  setSastBasePath,
  requestSastReports,
  receiveSastReports,
  receiveSastError,
  fetchSastReports,
  setSastContainerHeadPath,
  setSastContainerBasePath,
  requestSastContainerReports,
  receiveSastContainerReports,
  receiveSastContainerError,
  fetchSastContainerReports,
  setDastHeadPath,
  setDastBasePath,
  requestDastReports,
  receiveDastReports,
  receiveDastError,
  fetchDastReports,
  setDependencyScanningHeadPath,
  setDependencyScanningBasePath,
  requestDependencyScanningReports,
  receiveDependencyScanningError,
  receiveDependencyScanningReports,
  fetchDependencyScanningReports,
  openModal,
  setModalData,
  requestDismissVulnerability,
  receiveDismissVulnerability,
  receiveDismissVulnerabilityError,
  dismissVulnerability,
  revertDismissVulnerability,
  requestCreateIssue,
  receiveCreateIssue,
  receiveCreateIssueError,
  createNewIssue,
  downloadPatch,
  requestCreateMergeRequest,
  receiveCreateMergeRequestSuccess,
  receiveCreateMergeRequestError,
  createMergeRequest,
  updateSastIssue,
  updateDependencyScanningIssue,
  updateContainerScanningIssue,
  updateDastIssue,
  addDismissalComment,
  receiveAddDismissalCommentError,
  receiveAddDismissalCommentSuccess,
  requestAddDismissalComment,
} from 'ee/vue_shared/security_reports/store/actions';
import * as types from 'ee/vue_shared/security_reports/store/mutation_types';
import state from 'ee/vue_shared/security_reports/store/state';
import testAction from 'spec/helpers/vuex_action_helper';
import {
  sastIssues,
  sastIssuesBase,
  dast,
  dastBase,
  dockerReport,
  dockerBaseReport,
  sastFeedbacks,
  dastFeedbacks,
  containerScanningFeedbacks,
} from '../mock_data';

describe('security reports actions', () => {
  let mockedState;
  let mock;

  beforeEach(() => {
    mockedState = state();
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

  describe('setHeadBlobPath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setHeadBlobPath,
        'path',
        mockedState,
        [
          {
            type: types.SET_HEAD_BLOB_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setBaseBlobPath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setBaseBlobPath,
        'path',
        mockedState,
        [
          {
            type: types.SET_BASE_BLOB_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setVulnerabilityFeedbackPath', () => {
    it('should commit set vulnerabulity feedback path', done => {
      testAction(
        setVulnerabilityFeedbackPath,
        'path',
        mockedState,
        [
          {
            type: types.SET_VULNERABILITY_FEEDBACK_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setVulnerabilityFeedbackHelpPath', () => {
    it('should commit set vulnerabulity feedback help path', done => {
      testAction(
        setVulnerabilityFeedbackHelpPath,
        'path',
        mockedState,
        [
          {
            type: types.SET_VULNERABILITY_FEEDBACK_HELP_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setPipelineId', () => {
    it('should commit set vulnerability feedback path', done => {
      testAction(
        setPipelineId,
        123,
        mockedState,
        [
          {
            type: types.SET_PIPELINE_ID,
            payload: 123,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setCanCreateIssuePermission', () => {
    it('should commit set can create issue permission', done => {
      testAction(
        setCanCreateIssuePermission,
        true,
        mockedState,
        [
          {
            type: types.SET_CAN_CREATE_ISSUE_PERMISSION,
            payload: true,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setCanCreateFeedbackPermission', () => {
    it('should commit set can create feedback permission', done => {
      testAction(
        setCanCreateFeedbackPermission,
        true,
        mockedState,
        [
          {
            type: types.SET_CAN_CREATE_FEEDBACK_PERMISSION,
            payload: true,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setSastHeadPath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setSastHeadPath,
        'path',
        mockedState,
        [
          {
            type: types.SET_SAST_HEAD_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setSastBasePath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setSastBasePath,
        'path',
        mockedState,
        [
          {
            type: types.SET_SAST_BASE_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('requestSastReports', () => {
    it('should commit request mutation', done => {
      testAction(
        requestSastReports,
        null,
        mockedState,
        [
          {
            type: types.REQUEST_SAST_REPORTS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveSastReports', () => {
    it('should commit request mutation', done => {
      testAction(
        receiveSastReports,
        {},
        mockedState,
        [
          {
            type: types.RECEIVE_SAST_REPORTS,
            payload: {},
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveSastError', () => {
    it('should commit sast error mutation', done => {
      const error = new Error('test');

      testAction(
        receiveSastError,
        error,
        mockedState,
        [
          {
            type: types.RECEIVE_SAST_REPORTS_ERROR,
            payload: error,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('fetchSastReports', () => {
    describe('with head and base', () => {
      it('should dispatch `receiveSastReports`', done => {
        mock.onGet('foo').reply(200, sastIssues);
        mock.onGet('bar').reply(200, sastIssuesBase);
        mock
          .onGet('vulnerabilities_path', {
            params: {
              category: 'sast',
            },
          })
          .reply(200, sastFeedbacks);

        mockedState.sast.paths.head = 'foo';
        mockedState.sast.paths.base = 'bar';
        mockedState.vulnerabilityFeedbackPath = 'vulnerabilities_path';
        testAction(
          fetchSastReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestSastReports',
            },
            {
              type: 'receiveSastReports',
              payload: { head: sastIssues, base: sastIssuesBase, enrichData: sastFeedbacks },
            },
          ],
          done,
        );
      });

      it('should dispatch `receiveSastError`', done => {
        mock.onGet('foo').reply(500, {});
        mockedState.sast.paths.head = 'foo';
        mockedState.sast.paths.base = 'bar';

        testAction(
          fetchSastReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestSastReports',
            },
            {
              type: 'receiveSastError',
            },
          ],
          done,
        );
      });
    });

    describe('with head', () => {
      it('should dispatch `receiveSastReports`', done => {
        mock.onGet('foo').reply(200, sastIssues);
        mock
          .onGet('vulnerabilities_path', {
            params: {
              category: 'sast',
            },
          })
          .reply(200, sastFeedbacks);

        mockedState.sast.paths.head = 'foo';
        mockedState.vulnerabilityFeedbackPath = 'vulnerabilities_path';

        testAction(
          fetchSastReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestSastReports',
            },
            {
              type: 'receiveSastReports',
              payload: { head: sastIssues, base: null, enrichData: sastFeedbacks },
            },
          ],
          done,
        );
      });

      it('should dispatch `receiveSastError`', done => {
        mock.onGet('foo').reply(500, {});
        mockedState.sast.paths.head = 'foo';

        testAction(
          fetchSastReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestSastReports',
            },
            {
              type: 'receiveSastError',
            },
          ],
          done,
        );
      });
    });
  });

  describe('setSastContainerHeadPath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setSastContainerHeadPath,
        'path',
        mockedState,
        [
          {
            type: types.SET_SAST_CONTAINER_HEAD_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setSastContainerBasePath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setSastContainerBasePath,
        'path',
        mockedState,
        [
          {
            type: types.SET_SAST_CONTAINER_BASE_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('requestSastContainerReports', () => {
    it('should commit request mutation', done => {
      testAction(
        requestSastContainerReports,
        null,
        mockedState,
        [
          {
            type: types.REQUEST_SAST_CONTAINER_REPORTS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveSastContainerReports', () => {
    it('should commit sast receive mutation', done => {
      testAction(
        receiveSastContainerReports,
        {},
        mockedState,
        [
          {
            type: types.RECEIVE_SAST_CONTAINER_REPORTS,
            payload: {},
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveSastContainerError', () => {
    it('should commit sast error mutation', done => {
      const error = new Error('test');

      testAction(
        receiveSastContainerError,
        error,
        mockedState,
        [
          {
            type: types.RECEIVE_SAST_CONTAINER_ERROR,
            payload: error,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('fetchSastContainerReports', () => {
    describe('with head and base', () => {
      it('should dispatch `receiveSastContainerReports`', done => {
        mock.onGet('foo').reply(200, dockerReport);
        mock.onGet('bar').reply(200, dockerBaseReport);
        mock
          .onGet('vulnerabilities_path', {
            params: {
              category: 'container_scanning',
            },
          })
          .reply(200, containerScanningFeedbacks);

        mockedState.vulnerabilityFeedbackPath = 'vulnerabilities_path';
        mockedState.sastContainer.paths.head = 'foo';
        mockedState.sastContainer.paths.base = 'bar';

        testAction(
          fetchSastContainerReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestSastContainerReports',
            },
            {
              type: 'receiveSastContainerReports',
              payload: {
                head: dockerReport,
                base: dockerBaseReport,
                enrichData: containerScanningFeedbacks,
              },
            },
          ],
          done,
        );
      });

      it('should dispatch `receiveSastContainerError`', done => {
        mock.onGet('foo').reply(500, {});
        mockedState.sastContainer.paths.head = 'foo';
        mockedState.sastContainer.paths.base = 'bar';

        testAction(
          fetchSastContainerReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestSastContainerReports',
            },
            {
              type: 'receiveSastContainerError',
            },
          ],
          done,
        );
      });
    });

    describe('with head', () => {
      it('should dispatch `receiveSastContainerReports`', done => {
        mock.onGet('foo').reply(200, dockerReport);
        mock
          .onGet('vulnerabilities_path', {
            params: {
              category: 'container_scanning',
            },
          })
          .reply(200, containerScanningFeedbacks);

        mockedState.vulnerabilityFeedbackPath = 'vulnerabilities_path';

        mockedState.sastContainer.paths.head = 'foo';

        testAction(
          fetchSastContainerReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestSastContainerReports',
            },
            {
              type: 'receiveSastContainerReports',
              payload: { head: dockerReport, base: null, enrichData: containerScanningFeedbacks },
            },
          ],
          done,
        );
      });

      it('should dispatch `receiveSastError`', done => {
        mock.onGet('foo').reply(500, {});
        mockedState.sastContainer.paths.head = 'foo';

        testAction(
          fetchSastContainerReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestSastContainerReports',
            },
            {
              type: 'receiveSastContainerError',
            },
          ],
          done,
        );
      });
    });
  });

  describe('setDastHeadPath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setDastHeadPath,
        'path',
        mockedState,
        [
          {
            type: types.SET_DAST_HEAD_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setDastBasePath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setDastBasePath,
        'path',
        mockedState,
        [
          {
            type: types.SET_DAST_BASE_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('requestDastReports', () => {
    it('should commit request mutation', done => {
      testAction(
        requestDastReports,
        null,
        mockedState,
        [
          {
            type: types.REQUEST_DAST_REPORTS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveDastReports', () => {
    it('should commit sast receive mutation', done => {
      testAction(
        receiveDastReports,
        {},
        mockedState,
        [
          {
            type: types.RECEIVE_DAST_REPORTS,
            payload: {},
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveDastError', () => {
    it('should commit sast error mutation', done => {
      const error = new Error('test');

      testAction(
        receiveDastError,
        error,
        mockedState,
        [
          {
            type: types.RECEIVE_DAST_ERROR,
            payload: error,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('fetchDastReports', () => {
    describe('with head and base', () => {
      it('should dispatch `receiveDastReports`', done => {
        mock.onGet('foo').reply(200, dast);
        mock.onGet('bar').reply(200, dastBase);

        mock
          .onGet('vulnerabilities_path', {
            params: {
              category: 'dast',
            },
          })
          .reply(200, dastFeedbacks);

        mockedState.vulnerabilityFeedbackPath = 'vulnerabilities_path';
        mockedState.dast.paths.head = 'foo';
        mockedState.dast.paths.base = 'bar';

        testAction(
          fetchDastReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDastReports',
            },
            {
              type: 'receiveDastReports',
              payload: { head: dast, base: dastBase, enrichData: dastFeedbacks },
            },
          ],
          done,
        );
      });

      it('should dispatch `receiveDastError`', done => {
        mock.onGet('foo').reply(500, {});
        mockedState.dast.paths.head = 'foo';
        mockedState.dast.paths.base = 'bar';

        testAction(
          fetchDastReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDastReports',
            },
            {
              type: 'receiveDastError',
            },
          ],
          done,
        );
      });
    });

    describe('with head', () => {
      it('should dispatch `receiveSastContainerReports`', done => {
        mock.onGet('foo').reply(200, dast);
        mock
          .onGet('vulnerabilities_path', {
            params: {
              category: 'dast',
            },
          })
          .reply(200, dastFeedbacks);

        mockedState.vulnerabilityFeedbackPath = 'vulnerabilities_path';
        mockedState.dast.paths.head = 'foo';

        testAction(
          fetchDastReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDastReports',
            },
            {
              type: 'receiveDastReports',
              payload: { head: dast, base: null, enrichData: dastFeedbacks },
            },
          ],
          done,
        );
      });

      it('should dispatch `receiveSastError`', done => {
        mock.onGet('foo').reply(500, {});
        mockedState.dast.paths.head = 'foo';

        testAction(
          fetchDastReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDastReports',
            },
            {
              type: 'receiveDastError',
            },
          ],
          done,
        );
      });
    });
  });

  describe('setDependencyScanningHeadPath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setDependencyScanningHeadPath,
        'path',
        mockedState,
        [
          {
            type: types.SET_DEPENDENCY_SCANNING_HEAD_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setDependencyScanningBasePath', () => {
    it('should commit set head blob path', done => {
      testAction(
        setDependencyScanningBasePath,
        'path',
        mockedState,
        [
          {
            type: types.SET_DEPENDENCY_SCANNING_BASE_PATH,
            payload: 'path',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('requestDependencyScanningReports', () => {
    it('should commit request mutation', done => {
      testAction(
        requestDependencyScanningReports,
        null,
        mockedState,
        [
          {
            type: types.REQUEST_DEPENDENCY_SCANNING_REPORTS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveDependencyScanningReports', () => {
    it('should commit sast receive mutation', done => {
      testAction(
        receiveDependencyScanningReports,
        {},
        mockedState,
        [
          {
            type: types.RECEIVE_DEPENDENCY_SCANNING_REPORTS,
            payload: {},
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveDependencyScanningError', () => {
    it('should commit sast error mutation', done => {
      const error = new Error('test');

      testAction(
        receiveDependencyScanningError,
        error,
        mockedState,
        [
          {
            type: types.RECEIVE_DEPENDENCY_SCANNING_ERROR,
            payload: error,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('fetchDependencyScanningReports', () => {
    describe('with head and base', () => {
      it('should dispatch `receiveDependencyScanningReports`', done => {
        mock.onGet('foo').reply(200, sastIssues);
        mock.onGet('bar').reply(200, sastIssuesBase);
        mock
          .onGet('vulnerabilities_path', {
            params: {
              category: 'dependency_scanning',
            },
          })
          .reply(200, sastFeedbacks);

        mockedState.vulnerabilityFeedbackPath = 'vulnerabilities_path';
        mockedState.dependencyScanning.paths.head = 'foo';
        mockedState.dependencyScanning.paths.base = 'bar';

        testAction(
          fetchDependencyScanningReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDependencyScanningReports',
            },
            {
              type: 'receiveDependencyScanningReports',
              payload: { head: sastIssues, base: sastIssuesBase, enrichData: sastFeedbacks },
            },
          ],
          done,
        );
      });

      it('should dispatch `receiveDependencyScanningError`', done => {
        mock.onGet('foo').reply(500, {});
        mockedState.dependencyScanning.paths.head = 'foo';
        mockedState.dependencyScanning.paths.base = 'bar';

        testAction(
          fetchDependencyScanningReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDependencyScanningReports',
            },
            {
              type: 'receiveDependencyScanningError',
            },
          ],
          done,
        );
      });
    });

    describe('with head', () => {
      it('should dispatch `receiveDependencyScanningReports`', done => {
        mock.onGet('foo').reply(200, sastIssues);
        mock
          .onGet('vulnerabilities_path', {
            params: {
              category: 'dependency_scanning',
            },
          })
          .reply(200, sastFeedbacks);

        mockedState.vulnerabilityFeedbackPath = 'vulnerabilities_path';
        mockedState.dependencyScanning.paths.head = 'foo';

        testAction(
          fetchDependencyScanningReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDependencyScanningReports',
            },
            {
              type: 'receiveDependencyScanningReports',
              payload: { head: sastIssues, base: null, enrichData: sastFeedbacks },
            },
          ],
          done,
        );
      });

      it('should dispatch `receiveDependencyScanningError`', done => {
        mock.onGet('foo').reply(500, {});
        mockedState.dependencyScanning.paths.head = 'foo';

        testAction(
          fetchDependencyScanningReports,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDependencyScanningReports',
            },
            {
              type: 'receiveDependencyScanningError',
            },
          ],
          done,
        );
      });
    });
  });

  describe('openModal', () => {
    it('dispatches setModalData action', done => {
      testAction(
        openModal,
        { issue: { id: 1 }, status: 'failed' },
        mockedState,
        [],
        [
          {
            type: 'setModalData',
            payload: { issue: { id: 1 }, status: 'failed' },
          },
        ],
        done,
      );
    });
  });

  describe('setModalData', () => {
    it('commits set issue modal data', done => {
      testAction(
        setModalData,
        { issue: { id: 1 }, status: 'success' },
        mockedState,
        [
          {
            type: types.SET_ISSUE_MODAL_DATA,
            payload: { issue: { id: 1 }, status: 'success' },
          },
        ],
        [],
        done,
      );
    });
  });

  describe('requestDismissVulnerability', () => {
    it('commits request dismiss issue', done => {
      testAction(
        requestDismissVulnerability,
        null,
        mockedState,
        [
          {
            type: types.REQUEST_DISMISS_VULNERABILITY,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveDismissVulnerability', () => {
    it('commits receive dismiss issue', done => {
      testAction(
        receiveDismissVulnerability,
        null,
        mockedState,
        [
          {
            type: types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveDismissVulnerabilityError', () => {
    it('commits receive dismiss issue error with payload', done => {
      testAction(
        receiveDismissVulnerabilityError,
        'error',
        mockedState,
        [
          {
            type: types.RECEIVE_DISMISS_VULNERABILITY_ERROR,
            payload: 'error',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('dismissVulnerability', () => {
    describe('with success', () => {
      let dismissalFeedback;
      beforeEach(() => {
        dismissalFeedback = {
          foo: 'bar',
        };
        mock.onPost('dismiss_vulnerability_path').reply(200, dismissalFeedback);
        mockedState.createVulnerabilityFeedbackDismissalPath = 'dismiss_vulnerability_path';
      });

      it('with success should dispatch `receiveDismissVulnerability`', done => {
        testAction(
          dismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'closeDismissalCommentBox',
            },
            {
              type: 'receiveDismissVulnerability',
            },
          ],
          done,
        );
      });

      it('should dispatch `updateSastIssue` for sast issue', done => {
        mockedState.modal.vulnerability.category = 'sast';
        const expectedUpdatePayload = {
          ...mockedState.modal.vulnerability,
          isDismissed: true,
          dismissalFeedback,
        };

        testAction(
          dismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'closeDismissalCommentBox',
            },
            {
              type: 'receiveDismissVulnerability',
            },
            {
              type: 'updateSastIssue',
              payload: expectedUpdatePayload,
            },
          ],
          done,
        );
      });

      it('should dispatch `updateDependencyScanningIssue` for dependency scanning issue', done => {
        mockedState.modal.vulnerability.category = 'dependency_scanning';
        const expectedUpdatePayload = {
          ...mockedState.modal.vulnerability,
          isDismissed: true,
          dismissalFeedback,
        };

        testAction(
          dismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'closeDismissalCommentBox',
            },
            {
              type: 'receiveDismissVulnerability',
            },
            {
              type: 'updateDependencyScanningIssue',
              payload: expectedUpdatePayload,
            },
          ],
          done,
        );
      });

      it('should dispatch `updateContainerScanningIssue` for container scanning issue', done => {
        mockedState.modal.vulnerability.category = 'container_scanning';
        const expectedUpdatePayload = {
          ...mockedState.modal.vulnerability,
          isDismissed: true,
          dismissalFeedback,
        };

        testAction(
          dismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'closeDismissalCommentBox',
            },
            {
              type: 'receiveDismissVulnerability',
            },
            {
              type: 'updateContainerScanningIssue',
              payload: expectedUpdatePayload,
            },
          ],
          done,
        );
      });

      it('should dispatch `updateDastIssue` for dast issue', done => {
        mockedState.modal.vulnerability.category = 'dast';
        const expectedUpdatePayload = {
          ...mockedState.modal.vulnerability,
          isDismissed: true,
          dismissalFeedback,
        };

        testAction(
          dismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'closeDismissalCommentBox',
            },
            {
              type: 'receiveDismissVulnerability',
            },
            {
              type: 'updateDastIssue',
              payload: expectedUpdatePayload,
            },
          ],
          done,
        );
      });
    });

    it('with error should dispatch `receiveDismissVulnerabilityError`', done => {
      mock.onPost('dismiss_vulnerability_path').reply(500, {});
      mockedState.vulnerabilityFeedbackPath = 'dismiss_vulnerability_path';

      testAction(
        dismissVulnerability,
        null,
        mockedState,
        [],
        [
          {
            type: 'requestDismissVulnerability',
          },
          {
            type: 'receiveDismissVulnerabilityError',
            payload: 'There was an error dismissing the vulnerability. Please try again.',
          },
        ],
        done,
      );
    });
  });

  describe('addDismissalComment', () => {
    const vulnerability = {
      id: 0,
      vulnerability_feedback_dismissal_path: 'foo',
      dismissalFeedback: { id: 1 },
    };
    const data = { vulnerability };
    const url = `${state.createVulnerabilityFeedbackDismissalPath}/${vulnerability.dismissalFeedback.id}`;
    const comment = 'Well, we’re back in the car again.';

    describe('on success', () => {
      beforeEach(() => {
        mock.onPatch(url).replyOnce(200, data);
      });

      it('should dispatch the request and success actions', done => {
        testAction(
          addDismissalComment,
          { comment },
          { modal: { vulnerability } },
          [],
          [
            { type: 'requestAddDismissalComment' },
            { type: 'closeDismissalCommentBox' },
            {
              type: 'receiveAddDismissalCommentSuccess',
              payload: { data },
            },
          ],
          done,
        );
      });
    });

    describe('on error', () => {
      beforeEach(() => {
        mock.onPatch(url).replyOnce(404);
      });

      it('should dispatch the request and error actions', done => {
        testAction(
          addDismissalComment,
          { comment },
          { modal: { vulnerability } },
          [],
          [
            { type: 'requestAddDismissalComment' },
            {
              type: 'receiveAddDismissalCommentError',
              payload: 'There was an error adding the comment.',
            },
          ],
          done,
        );
      });
    });

    describe('receiveAddDismissalCommentSuccess', () => {
      it('should commit the success mutation', done => {
        testAction(
          receiveAddDismissalCommentSuccess,
          { data },
          state,
          [{ type: types.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS, payload: { data } }],
          [],
          done,
        );
      });
    });

    describe('receiveAddDismissalCommentError', () => {
      it('should commit the error mutation', done => {
        testAction(
          receiveAddDismissalCommentError,
          {},
          state,
          [
            {
              type: types.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR,
              payload: {},
            },
          ],
          [],
          done,
        );
      });
    });

    describe('requestAddDismissalComment', () => {
      it('should commit the request mutation', done => {
        testAction(
          requestAddDismissalComment,
          {},
          state,
          [{ type: types.REQUEST_ADD_DISMISSAL_COMMENT }],
          [],
          done,
        );
      });
    });
  });

  describe('revertDismissVulnerability', () => {
    describe('with success', () => {
      beforeEach(() => {
        mock.onDelete('dismiss_vulnerability_path/123').reply(200, {});
        mockedState.modal.vulnerability.dismissalFeedback = {
          id: 123,
          destroy_vulnerability_feedback_dismissal_path: 'dismiss_vulnerability_path/123',
        };
      });

      it('should dispatch `receiveDismissVulnerability`', done => {
        testAction(
          revertDismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'receiveDismissVulnerability',
            },
          ],
          done,
        );
      });

      it('should dispatch `updateSastIssue` for sast issue', done => {
        mockedState.modal.vulnerability.category = 'sast';
        const expectedUpdatePayload = {
          ...mockedState.modal.vulnerability,
          isDismissed: false,
          dismissalFeedback: null,
        };

        testAction(
          revertDismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'receiveDismissVulnerability',
            },
            {
              type: 'updateSastIssue',
              payload: expectedUpdatePayload,
            },
          ],
          done,
        );
      });

      it('should dispatch `updateDependencyScanningIssue` for dependency scanning issue', done => {
        mockedState.modal.vulnerability.category = 'dependency_scanning';
        const expectedUpdatePayload = {
          ...mockedState.modal.vulnerability,
          isDismissed: false,
          dismissalFeedback: null,
        };

        testAction(
          revertDismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'receiveDismissVulnerability',
            },
            {
              type: 'updateDependencyScanningIssue',
              payload: expectedUpdatePayload,
            },
          ],
          done,
        );
      });

      it('should dispatch `updateContainerScanningIssue` for container scanning issue', done => {
        mockedState.modal.vulnerability.category = 'container_scanning';
        const expectedUpdatePayload = {
          ...mockedState.modal.vulnerability,
          isDismissed: false,
          dismissalFeedback: null,
        };

        testAction(
          revertDismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'receiveDismissVulnerability',
            },
            {
              type: 'updateContainerScanningIssue',
              payload: expectedUpdatePayload,
            },
          ],
          done,
        );
      });

      it('should dispatch `updateDastIssue` for dast issue', done => {
        mockedState.modal.vulnerability.category = 'dast';
        const expectedUpdatePayload = {
          ...mockedState.modal.vulnerability,
          isDismissed: false,
          dismissalFeedback: null,
        };

        testAction(
          revertDismissVulnerability,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestDismissVulnerability',
            },
            {
              type: 'receiveDismissVulnerability',
            },
            {
              type: 'updateDastIssue',
              payload: expectedUpdatePayload,
            },
          ],
          done,
        );
      });
    });

    it('with error should dispatch `receiveDismissVulnerabilityError`', done => {
      mock.onDelete('dismiss_vulnerability_path/123').reply(500, {});
      mockedState.modal.vulnerability.dismissalFeedback = { id: 123 };
      mockedState.createVulnerabilityFeedbackDismissalPath = 'dismiss_vulnerability_path';

      testAction(
        revertDismissVulnerability,
        null,
        mockedState,
        [],
        [
          {
            type: 'requestDismissVulnerability',
          },
          {
            type: 'receiveDismissVulnerabilityError',
            payload: 'There was an error reverting the dismissal. Please try again.',
          },
        ],
        done,
      );
    });
  });

  describe('requestCreateIssue', () => {
    it('commits request create issue', done => {
      testAction(
        requestCreateIssue,
        null,
        mockedState,
        [
          {
            type: types.REQUEST_CREATE_ISSUE,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveCreateIssue', () => {
    it('commits receive create issue', done => {
      testAction(
        receiveCreateIssue,
        null,
        mockedState,
        [
          {
            type: types.RECEIVE_CREATE_ISSUE_SUCCESS,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveCreateIssueError', () => {
    it('commits receive create issue error with payload', done => {
      testAction(
        receiveCreateIssueError,
        'error',
        mockedState,
        [
          {
            type: types.RECEIVE_CREATE_ISSUE_ERROR,
            payload: 'error',
          },
        ],
        [],
        done,
      );
    });
  });

  describe('createNewIssue', () => {
    beforeEach(() => {
      spyOnDependency(actions, 'visitUrl');
    });

    it('with success should dispatch `receiveDismissVulnerability`', done => {
      mock.onPost('create_issue_path').reply(200, { issue_path: 'new_issue' });
      mockedState.createVulnerabilityFeedbackIssuePath = 'create_issue_path';

      testAction(
        createNewIssue,
        null,
        mockedState,
        [],
        [
          {
            type: 'requestCreateIssue',
          },
          {
            type: 'receiveCreateIssue',
          },
        ],
        done,
      );
    });

    it('with error should dispatch `receiveCreateIssueError`', done => {
      mock.onPost('create_issue_path').reply(500, {});
      mockedState.vulnerabilityFeedbackPath = 'create_issue_path';

      testAction(
        createNewIssue,
        null,
        mockedState,
        [],
        [
          {
            type: 'requestCreateIssue',
          },
          {
            type: 'receiveCreateIssueError',
            payload: 'There was an error creating the issue. Please try again.',
          },
        ],
        done,
      );
    });
  });

  describe('downloadPatch', () => {
    it('creates a download link and clicks on it to download the file', () => {
      spyOn(document, 'createElement').and.callThrough();
      spyOn(document.body, 'appendChild').and.callThrough();
      spyOn(document.body, 'removeChild').and.callThrough();

      downloadPatch({
        state: {
          modal: {
            vulnerability: {
              remediations: [
                {
                  diff: 'abcdef',
                },
              ],
            },
          },
        },
      });

      expect(document.createElement).toHaveBeenCalledTimes(1);
      expect(document.body.appendChild).toHaveBeenCalledTimes(1);
      expect(document.body.removeChild).toHaveBeenCalledTimes(1);
    });
  });

  describe('requestCreateMergeRequest', () => {
    it('commits request create merge request', done => {
      testAction(
        requestCreateMergeRequest,
        null,
        mockedState,
        [
          {
            type: types.REQUEST_CREATE_MERGE_REQUEST,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveCreateMergeRequestSuccess', () => {
    it('commits receive create merge request', done => {
      const data = { foo: 'bar' };

      testAction(
        receiveCreateMergeRequestSuccess,
        data,
        mockedState,
        [
          {
            type: types.RECEIVE_CREATE_MERGE_REQUEST_SUCCESS,
            payload: data,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveCreateMergeRequestError', () => {
    it('commits receive create merge request error', done => {
      testAction(
        receiveCreateMergeRequestError,
        '',
        mockedState,
        [
          {
            type: types.RECEIVE_CREATE_MERGE_REQUEST_ERROR,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('createMergeRequest', () => {
    beforeEach(() => {
      spyOnDependency(actions, 'visitUrl');
    });

    it('with success should dispatch `receiveCreateMergeRequestSuccess`', done => {
      const data = { merge_request_path: 'fakepath.html' };
      mockedState.createVulnerabilityFeedbackMergeRequestPath = 'create_merge_request_path';
      mock.onPost('create_merge_request_path').reply(200, data);

      testAction(
        createMergeRequest,
        null,
        mockedState,
        [],
        [
          {
            type: 'requestCreateMergeRequest',
          },
          {
            type: 'receiveCreateMergeRequestSuccess',
            payload: data,
          },
        ],
        done,
      );
    });

    it('with error should dispatch `receiveCreateMergeRequestError`', done => {
      mock.onPost('create_merge_request_path').reply(500, {});
      mockedState.vulnerabilityFeedbackPath = 'create_merge_request_path';

      testAction(
        createMergeRequest,
        null,
        mockedState,
        [],
        [
          {
            type: 'requestCreateMergeRequest',
          },
          {
            type: 'receiveCreateMergeRequestError',
            payload: 'There was an error creating the merge request. Please try again.',
          },
        ],
        done,
      );
    });
  });

  describe('updateSastIssue', () => {
    it('commits update sast issue', done => {
      const payload = { foo: 'bar' };

      testAction(
        updateSastIssue,
        payload,
        mockedState,
        [
          {
            type: types.UPDATE_SAST_ISSUE,
            payload,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('updateDependencyScanningIssue', () => {
    it('commits update dependency scanning issue', done => {
      const payload = { foo: 'bar' };

      testAction(
        updateDependencyScanningIssue,
        payload,
        mockedState,
        [
          {
            type: types.UPDATE_DEPENDENCY_SCANNING_ISSUE,
            payload,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('updateContainerScanningIssue', () => {
    it('commits update container scanning issue', done => {
      const payload = { foo: 'bar' };

      testAction(
        updateContainerScanningIssue,
        payload,
        mockedState,
        [
          {
            type: types.UPDATE_CONTAINER_SCANNING_ISSUE,
            payload,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('updateDastIssue', () => {
    it('commits update dast issue', done => {
      const payload = { foo: 'bar' };

      testAction(
        updateDastIssue,
        payload,
        mockedState,
        [
          {
            type: types.UPDATE_DAST_ISSUE,
            payload,
          },
        ],
        [],
        done,
      );
    });
  });
});
