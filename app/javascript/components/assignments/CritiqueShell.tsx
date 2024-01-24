import React, { Suspense, useState, useEffect, useReducer } from "react";
import { useParams } from "react-router-dom";

//Redux store stuff
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { useDispatch } from "react-redux";
import {DateTime} from 'luxon';
import parse from 'html-react-parser';
import { useTranslation } from "react-i18next";
import { IRubricData, ICriteria } from "./RubricViewer";
import { ISubmissionCondensed } from "./AssignmentViewer";

import Grid from "@mui/material/Unstable_Grid2";
import { ToggleButton, ToggleButtonGroup, Typography } from "@mui/material";

import RubricScorer, { IRubricRowFeedback } from "./RubricScorer";
import { ISubmissionFeedback } from "./RubricScorer";
import AdminListToolbar from "../infrastructure/AdminListToolbar";
import { Column } from "primereact/column";
import { DataTable } from "primereact/datatable";
import { Panel } from "primereact/panel";

enum SubmissionActions{
  init_no_data = 'INIT NO DATA',
  set_submission_full = 'SET SUBMISSION FULL',
  set_submission_feedback_full = 'SET FEEDBACK FULL',
  set_feedback_overall = 'SET FEEDBACK OVERALL',
  set_recorded_score = 'SET RECORDED SCORE',
  set_criteria = 'SET CRITERIA',
  set_criteria_feedback = 'SET CRITERIA FEEDBACK',
  set_criteria_score = 'SET CRITERIA SCORE',

  
}

const genCleanFeedback = ( submission_id:number, rubric:IRubricData ):ISubmissionFeedback =>{
  const submissionFeedback:ISubmissionFeedback = {
    id: null,
    submission_id: submission_id,
    feedback: '',
    rubric_row_feedbacks: []
  }
  rubric.criteria.forEach( (value:ICriteria) =>{
    const newRowFeedback: IRubricRowFeedback = {
      id: null,
      submission_feedback_id: null,
      criterium_id: value.id,
      score: 0,
      feedback: '',
    }
    submissionFeedback.rubric_row_feedbacks.push( newRowFeedback );
  })
  return submissionFeedback;

};

const genCleanSubmission = ( submission_id:number, rubric:IRubricData ):ISubmissionData =>{
      return {
        id: 0,
        recordedScore: null,
        submitted: null,
        withdrawn: null,
        sub_text: null,
        sub_link: null,
        rubric: rubric,
        submission_feedback: genCleanFeedback( submission_id, rubric )

      };

}

const SubmissionReducer = ( state, action ) =>{
  const tmpSubmission : ISubmissionData = Object.assign({}, state );

  var local_rubric_row_feedback = null;
  switch( action.type ){
    case SubmissionActions.init_no_data:
      return  genCleanSubmission( action.submission_id, action.rubric );

    case SubmissionActions.set_submission_full:
      return {...action.submission as ISubmissionData};
    case SubmissionActions.set_submission_feedback_full:
      tmpSubmission.submission_feedback = action.submission_feedback
      return Object.assign({}, tmpSubmission );
    case SubmissionActions.set_feedback_overall:
      tmpSubmission.submission_feedback.feedback = action.submission_feedback;
      return Object.assign({}, tmpSubmission );
    case SubmissionActions.set_criteria:
      local_rubric_row_feedback = tmpSubmission.submission_feedback.rubric_row_feedbacks.find( candidate => candidate.criterium_id === action.rubric_row_feedback.criterium_id );
      Object.assign( local_rubric_row_feedback, action.rubric_row_feedback );
      return tmpSubmission
    case SubmissionActions.set_criteria_feedback:
      local_rubric_row_feedback = tmpSubmission.submission_feedback.rubric_row_feedbacks.find( candidate => candidate.criterium_id === action.criterium_id );
      local_rubric_row_feedback.feedback = action.criterium_feedback;
      return tmpSubmission
    case SubmissionActions.set_criteria_score:
      local_rubric_row_feedback = tmpSubmission.submission_feedback.rubric_row_feedbacks.find( candidate => candidate.criterium_id === action.criterium_id );
      local_rubric_row_feedback.score = action.score;
      return tmpSubmission
    case SubmissionActions.set_recorded_score:
      tmpSubmission.recordedScore = action.recorded_score;
      return tmpSubmission;
    default:
      const msg = 'no action taken in submissionReducer';
      console.log( msg );
      throw new Error( msg );
  }
}
interface ISubmissionData{
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
  const dispatch = useDispatch( );

  const { assignmentId } = useParams( );
  const [filterText, setFilterText] = useState("");
  const [visibleColumns, setVisibleColumns] = useState([]);

  const [t, i18n] = useTranslation( `${category}s` );
  const [panels, setPanels] = useState( () => ['submissions'] )
  const [submissionsIndex, setSubmissionsIndex] = useState( Array<ISubmissionCondensed> );
  const [assignmentAcceptsText, setAssignmentAcceptsText] = useState( false );
  const [assignmentAcceptsLink, setAssignmentAcceptsLink] = useState( false );
  const [assignmentGroupEnabled, setAssignmentGroupEnabled] = useState( false );

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
    t( OPT_COLS.ID ),
    t( OPT_COLS.RECORDED_SCORE ),
    t( OPT_COLS.CALCULATED_SCORE ),
    t( OPT_COLS.WITHDRAWN)
  ]

  //Retrieve the submission
  const loadSubmission = (submissionId:number) => {
    dispatch( startTask());
    const url = `${endpoints.showUrl}${submissionId}.json`;
    axios.get( url )
      .then(response => {
        const data = response.data as {
          submission: ISubmissionData,
          rubric: IRubricData
        };
        if( data.submission.submission_feedback === undefined ){
          data.submission.submission_feedback = genCleanFeedback( data.submission.id, data.submission.rubric );
        }

        updateSelectedSubmission({type: SubmissionActions.set_submission_full, submission: data.submission} );

        if( !panels.includes('submitted') ){
          const tmpPanels = [...panels, 'submitted'];
          setPanels( tmpPanels );
        }
      }).finally( () =>{
        dispatch( endTask() );
      })
  }

  const handlePaneSelection = (
    event: React.MouseEvent<HTMLElement>,
    newPanes: string[],
  ) => {
    setPanels( newPanes );
  };

  useEffect( () => {
    if( endpointsLoaded ){
      getSubmissions( );
    }
  }, [endpointsLoaded]);

  const getSubmissions = () => {
    dispatch( startTask());
    const url = `${endpoints.baseUrl}${assignmentId}.json`;
    axios.get( url )
      .then(response => {
        const data = response.data;
        setAssignmentAcceptsText( data.assignment.text_sub );
        setAssignmentAcceptsLink( data.assignment.link_sub );
        setAssignmentGroupEnabled( data.assignment.group_enabled );
        data.assignment.submissions.forEach( (submission: ISubmissionCondensed) =>{
          submission.submitted = submission.submitted !== null ? DateTime.fromISO( submission.submitted) : null;
          submission.withdrawn = submission.withdrawn !== null ? DateTime.fromISO( submission.withdrawn) : null;
        })
        setSubmissionsIndex( data.assignment.submissions );
        
      })
  }

  return (
    <Panel header={t('critique_title')}>
    <Grid container columns={12}>
    <Grid display={'flex'}
      justifyContent={'center'}
      alignItems={'center'}
      xs={12} >
      <ToggleButtonGroup
        size="small"
        value={panels}
        onChange={handlePaneSelection}
        aria-label="panels">
        <ToggleButton value='submissions' aria-label={t('submissions_title')}>
          {t('submissions_title')}
        </ToggleButton>
        <ToggleButton value='submitted' aria-label={t('submitted')}>
          {t('submitted')}
        </ToggleButton>
        <ToggleButton value='feedback' aria-label={t('feedback')}>
          {t('feedback')}
        </ToggleButton>
        <ToggleButton value='history' aria-label={t('history')}>
          {t('history')}
        </ToggleButton>
      </ToggleButtonGroup>

    </Grid>
      {panels.includes('submissions') ? (
        <Grid xs={12 / panels.length } >
          <Typography variant="h6">
            {t('submissions_title')}
          </Typography>
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
          loadSubmission( event.data.id );
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
              console.log( rowData );
              if( rowData.withdrawn === null ){
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
              console.log( rowData );
              if( rowData.withdrawn === null ){
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

        </Grid>
      ): null}
      {panels.includes('submitted') ? (
        <Grid xs={12 / panels.length } >
          <Typography variant="h6">
            {t('submitted')}
          </Typography>
          {assignmentAcceptsLink ? (
            <React.Fragment>
              <Typography variant="h6">
                {t('submitted_link')}:
              </Typography>
              <Typography id='sub_link'>
                <a href={selectedSubmission.sub_link}>{selectedSubmission.sub_link}</a>
              </Typography>
            </React.Fragment>
          ): null}
          {assignmentAcceptsText ? (
            <React.Fragment>
              <Typography variant='h6'>
                {t('submitted_text')}:
              </Typography>
              <Typography id='sub_text' variant="body1">
                {parse( selectedSubmission.sub_text || `<i>${t('no_text')}</i>` )}
              </Typography>
            </React.Fragment>
          ) : null }
        </Grid>
      ): null}
      {panels.includes('feedback') ? (
        <Grid xs={12 / panels.length } >
          <Typography variant="h6">
            {t('feedback')}
          </Typography>
          <RubricScorer submission={selectedSubmission} submissionReducer={updateSelectedSubmission} />
        </Grid>
      ): null}
      {panels.includes('history') ? (
        <Grid xs={12 / panels.length } >
          <Typography variant="h6">
            {t('history')}
          </Typography>
          {t('error.not_loaded')}
        </Grid>
      ): null}

    </Grid>

    
    </Panel>

  );
}
export { ISubmissionData, SubmissionActions };