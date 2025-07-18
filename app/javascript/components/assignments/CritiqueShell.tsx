import React, { useState, useEffect, useReducer } from "react";
import { useParams } from "react-router";
import axios from "axios";
import parse from 'html-react-parser';

//Redux store stuff
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useDispatch } from "react-redux";
import { DateTime } from 'luxon';
import { useTranslation } from "react-i18next";
import { IRubricData, ICriteria } from "./RubricViewer";
import { ISubmissionCondensed } from "./AssignmentViewer";

import RubricScorer, { IRubricRowFeedback } from "./RubricScorer";
import { ISubmissionFeedback } from "./RubricScorer";
import AdminListToolbar from "../toolbars/AdminListToolbar";

import { Column } from "primereact/column";
import { DataTable } from "primereact/datatable";
import { Panel } from "primereact/panel";
import { Col, Container, Row } from "react-grid-system";
import { Splitter, SplitterPanel } from "primereact/splitter";
import { SelectButton } from "primereact/selectbutton";
import { Inplace, InplaceContent, InplaceDisplay } from "primereact/inplace";

enum SubmissionActions {
  init_no_data = 'INIT NO DATA',
  set_submission_full = 'SET SUBMISSION FULL',
  set_submission_feedback_full = 'SET FEEDBACK FULL',
  set_feedback_overall = 'SET FEEDBACK OVERALL',
  set_recorded_score = 'SET RECORDED SCORE',
  set_criteria = 'SET CRITERIA',
  set_criteria_feedback = 'SET CRITERIA FEEDBACK',
  set_criteria_score = 'SET CRITERIA SCORE',


}

const genCleanFeedback = (submission_id: number, rubric: IRubricData): ISubmissionFeedback => {
  const submissionFeedback: ISubmissionFeedback = {
    id: null,
    submission_id: submission_id,
    feedback: '',
    rubric_row_feedbacks: []
  }
  rubric.criteria.forEach((value: ICriteria) => {
    const newRowFeedback: IRubricRowFeedback = {
      id: null,
      submission_feedback_id: null,
      criterium_id: value.id,
      score: 0,
      feedback: '',
    }
    submissionFeedback.rubric_row_feedbacks.push(newRowFeedback);
  })
  return submissionFeedback;

};

const genCleanSubmission = (submission_id: number, rubric: IRubricData): ISubmissionData => {
  return {
    id: 0,
    recordedScore: null,
    submitted: null,
    withdrawn: null,
    sub_text: null,
    sub_link: null,
    rubric: rubric,
    submission_feedback: genCleanFeedback(submission_id, rubric)

  };

}

const SubmissionReducer = (state, action) => {
  const tmpSubmission: ISubmissionData = Object.assign({}, state);

  var local_rubric_row_feedback = null;
  switch (action.type) {
    case SubmissionActions.init_no_data:
      return genCleanSubmission(action.submission_id, action.rubric);

    case SubmissionActions.set_submission_full:
      return { ...action.submission as ISubmissionData };
    case SubmissionActions.set_submission_feedback_full:
      tmpSubmission.submission_feedback = action.submission_feedback
      return Object.assign({}, tmpSubmission);
    case SubmissionActions.set_feedback_overall:
      tmpSubmission.submission_feedback.feedback = action.submission_feedback;
      return Object.assign({}, tmpSubmission);
    case SubmissionActions.set_criteria:
      local_rubric_row_feedback = tmpSubmission.submission_feedback.rubric_row_feedbacks.find(candidate => candidate.criterium_id === action.rubric_row_feedback.criterium_id);
      Object.assign(local_rubric_row_feedback, action.rubric_row_feedback);
      return tmpSubmission
    case SubmissionActions.set_criteria_feedback:
      local_rubric_row_feedback = tmpSubmission.submission_feedback.rubric_row_feedbacks.find(candidate => candidate.criterium_id === action.criterium_id);
      local_rubric_row_feedback.feedback = action.criterium_feedback;
      return tmpSubmission
    case SubmissionActions.set_criteria_score:
      local_rubric_row_feedback = tmpSubmission.submission_feedback.rubric_row_feedbacks.find(candidate => candidate.criterium_id === action.criterium_id);
      local_rubric_row_feedback.score = action.score;
      return tmpSubmission
    case SubmissionActions.set_recorded_score:
      tmpSubmission.recordedScore = action.recorded_score;
      return tmpSubmission;
    default:
      const msg = 'no action taken in submissionReducer';
      console.log(msg);
      throw new Error(msg);
  }
}
interface ISubmissionData {
  id: number;
  recordedScore: number;
  submitted: DateTime;
  withdrawn: DateTime;
  sub_text: string;
  sub_link: string;
  rubric: IRubricData;
  submission_feedback: ISubmissionFeedback;
}

type Props = {
  rootPath?: string;
};

enum OPT_COLS {
  ID = 'submissions.id',
  RECORDED_SCORE = 'submissions.score',
  CALCULATED_SCORE = 'submissions.calculated_score',
  SUBMITTED = 'submissions.submitted',
  WITHDRAWN = 'submissions.withdrawn',

}
export default function CritiqueShell(props: Props) {
  const category = "critique";
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const dispatch = useDispatch();

  const { assignmentId } = useParams();
  const [visibleColumns, setVisibleColumns] = useState([]);

  const [t] = useTranslation(`${category}s`);
  const [panels, setPanels] = useState(() => ['submissions'])
  const [submissionsIndex, setSubmissionsIndex] = useState(Array<ISubmissionCondensed>);
  const [assignmentAcceptsText, setAssignmentAcceptsText] = useState(false);
  const [assignmentAcceptsLink, setAssignmentAcceptsLink] = useState(false);
  const [assignmentGroupEnabled, setAssignmentGroupEnabled] = useState(false);

  const initialState: ISubmissionData = {
    id: 0,
    recordedScore: 0,
    submitted: new Date(),
    withdrawn: new Date(),
    sub_text: "",
    sub_link: "",
    rubric: {
      name: "",
      description: "",
      version: 0,
      criteria: []
    },
    submission_feedback: {
      id: 0,
      submission_id: 0,
      feedback: "",
      rubric_row_feedbacks: []
    }
  };

  const [selectedSubmission, updateSelectedSubmission] = useReducer(SubmissionReducer, initialState);

  const optColumns = [
    t(OPT_COLS.ID),
    t(OPT_COLS.RECORDED_SCORE),
    t(OPT_COLS.CALCULATED_SCORE),
    t(OPT_COLS.WITHDRAWN)
  ]

  //Retrieve the submission
  const loadSubmission = (submissionId: number) => {
    dispatch(startTask());
    const url = props.rootPath === undefined
      ? `${endpoints.showUrl}${submissionId}.json`
      : `/${props.rootPath}${endpoints.showUrl}${submissionId}.json`;
    axios.get(url)
      .then(response => {
        const data = response.data as {
          submission: ISubmissionData,
          rubric: IRubricData
        };
        if (data.submission.submission_feedback === undefined) {
          data.submission.submission_feedback = genCleanFeedback(data.submission.id, data.submission.rubric);
        }

        updateSelectedSubmission({ type: SubmissionActions.set_submission_full, submission: data.submission });

        if (!panels.includes('submitted')) {
          const tmpPanels = [...panels, 'submitted'];
          setPanels(tmpPanels);
        }
      }).finally(() => {
        dispatch(endTask());
      })
  }

  useEffect(() => {
    if (endpointsLoaded) {
      getSubmissions();
    }
  }, [endpointsLoaded]);

  const getSubmissions = () => {
    dispatch(startTask());
    const url = props.rootPath === undefined
      ? `${endpoints.baseUrl}${assignmentId}.json`
      : `/${props.rootPath}${endpoints.baseUrl}${assignmentId}.json`;
    axios.get(url)
      .then(response => {
        const data = response.data;
        setAssignmentAcceptsText(data.assignment.text_sub);
        setAssignmentAcceptsLink(data.assignment.link_sub);
        setAssignmentGroupEnabled(data.assignment.group_enabled);
        data.assignment.submissions.forEach((submission: ISubmissionCondensed) => {
          submission.submitted = submission.submitted !== null ? DateTime.fromISO(submission.submitted) : null;
          submission.withdrawn = submission.withdrawn !== null ? DateTime.fromISO(submission.withdrawn) : null;
        })
        setSubmissionsIndex(data.assignment.submissions);

      })
  }

  const panelDefs = [
    { name: 'submissions', label: t('submissions_title') },
    { name: 'submitted', label: t('submitted') },
    { name: 'feedback', label: t('feedback') },
    { name: 'history', label: t('history') },
  ];


  return (
    <Panel header={t('critique_title')}>
      <Container fluid>
        <Row>
          <Col xs={12} >
            <div className="card flex justify-content-center">
              <SelectButton
                value={panels}
                options={panelDefs}
                onChange={(e) => {
                  setPanels(e.value);
                }}
                optionLabel="label"
                optionValue="name"
                multiple
              />
            </div>
          </Col>
        </Row>
        <Row>
          <Col >
                <Panel
                  header={panelDefs[0].name}
                >
                  <Inplace
                    closable
                  >
                    <InplaceDisplay>{t('submission_list_hidden')}</InplaceDisplay>
                    <InplaceContent>

                      <DataTable
                        value={submissionsIndex}
                        resizableColumns
                        tableStyle={{
                          minWidth: '50rem'
                        }}
                        reorderableColumns
                        paginator
                        rows={5}
                        rowsPerPageOptions={
                          [5, 10, 20, submissionsIndex.length]
                        }
                        header={<AdminListToolbar
                          itemType={category}
                          columnToggle={{
                            optColumns: optColumns,
                            visibleColumns: visibleColumns,
                            setVisibleColumnsFunc: setVisibleColumns,
                          }}
                        />}
                        sortField="submitted"
                        sortOrder={-1}
                        paginatorDropdownAppendTo={'self'}
                        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
                        currentPageReportTemplate="{first} to {last} of {totalRecords}"
                        dataKey="id"
                        onRowClick={(event) => {
                          loadSubmission(event.data.id);
                        }}
                      >
                        <Column
                          columnKey="id"
                          key='id'
                          field="id"
                          sortable
                          header={t("submissions.id")} />
                        <Column
                          key='recorded_score'
                          field="recorded_score"
                          sortable
                          header={t("submissions.score")} />
                        <Column
                          field="calculated_score"
                          header={t("submissions.calculated_score")}
                          sortable
                          body={(rowData) => {
                            if (rowData.withdrawn === null) {
                              return <span>{t('submissions.score_na')}</span>;
                            } else {
                              const dt = DateTime.fromISO(rowData.withdrawn);
                              return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
                            }

                          }}
                        />
                        <Column
                          field="submitted"
                          sortable
                          header={t("submissions.submitted")}
                          body={(rowData) => {
                            const dt = DateTime.fromISO(rowData.submitted);
                            return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;

                          }}
                        />
                        <Column
                          field="withdrawn"
                          sortable
                          header={t("submissions.withdrawn")}
                          body={(rowData) => {
                            if (rowData.withdrawn === null) {
                              return <span>{t('submissions.not_withdrawn')}</span>;
                            } else {
                              const dt = DateTime.fromISO(rowData.withdrawn);
                              return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
                            }

                          }}
                        />
                        <Column
                          field="user"
                          sortable
                          sortField="user.last_name"
                          header={t("submissions.submitter")}
                          body={param => {
                            return `${param.user.last_name}, ${param.user.first_name}`;
                          }}
                        />
                      </DataTable>
                    </InplaceContent>
                  </Inplace>

                </Panel>
              <Splitter>
              <SplitterPanel>
                <Panel
                  header={panelDefs[1].name}
                >
                  {assignmentAcceptsLink ? (
                    <React.Fragment>
                      <h6>
                        {t('submitted_link')}:

                      </h6>
                      <p id='sub_link'>
                        <a href={selectedSubmission.sub_link}>{selectedSubmission.sub_link}</a>
                      </p>
                    </React.Fragment>
                  ) : null}
                  {assignmentAcceptsText ? (
                    <React.Fragment>
                      <h6>
                        {t('submitted_text')}:
                      </h6>
                        {parse(selectedSubmission.sub_text || `<i>${t('no_text')}</i>`)}
                    </React.Fragment>
                  ) : null}
                </Panel>
              </SplitterPanel>
              <SplitterPanel >
                <Panel
                  header={panelDefs[2].name}
                >
                  <RubricScorer submission={selectedSubmission} submissionReducer={updateSelectedSubmission} />
                </Panel>
              </SplitterPanel>
              <SplitterPanel>
                <Panel
                  header={panelDefs[3].name}
                >
                  {t('error.not_loaded')}
                </Panel>
              </SplitterPanel>
            </Splitter>
          </Col>
        </Row>

      </Container>
    </Panel >

  );
}
export { ISubmissionData, SubmissionActions };