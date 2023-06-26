import React, { Suspense, useState, useEffect, useReducer } from "react";
import { useParams } from "react-router-dom";

//Redux store stuff
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { useDispatch } from "react-redux";

import { useTranslation } from "react-i18next";
import { Link, ToggleButton, ToggleButtonGroup, Typography } from "@mui/material";
import { IRubricData, ICriteria } from "./RubricViewer";
import { ISubmissionCondensed } from "./AssignmentViewer";
import { DataGrid, GridRenderCellParams, GridRowModel, GridColDef, GridRowParams } from "@mui/x-data-grid";
import Grid from "@mui/material/Unstable_Grid2";
import {DateTime} from 'luxon';
import parse from 'html-react-parser';
import RubricScorer, { IRubricRowFeedback } from "./RubricScorer";
import { ISubmissionFeedback } from "./RubricScorer";

enum SubmissionActions{
  init_no_data = 'INIT NO DATA',
  set_feedback_full = 'INIT FEEDBACK FULL',
  set_feedback_header = 'INIT FEEDBACK HEADER',
  set_criteria = 'INIT CRITERIA',
  set_recorded_score = 'INIT RECORDED SCORE'
  
}

const genCleanFeedback = ( submission_id:number, rubric:IRubricData ):ISubmissionFeedback =>{
  const submissionFeedback:ISubmissionFeedback = {
    id: null,
    submission_id: submission_id,
    calculated_score: 0,
    feedback: '',
    rubric_row_feedbacks: []
  }
  console.log( rubric );
  rubric.criteria.forEach( (value:ICriteria) =>{
    const newRowFeedback: IRubricRowFeedback = {
      id: null,
      submission_feedback_id: null,
      criterium_id: value.id,
      score: 0,
      feedback: ''
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
        submissionFeedback: genCleanFeedback( submission_id, rubric )

      };

}


const SubmissionReducer = ( state, action ) =>{
  const tmpSubmission : ISubmissionData = Object.assign({}, state );

  switch( action.type ){
    case SubmissionActions.init_no_data:
      return  genCleanSubmission( action.submission_id, action.rubric );

    case SubmissionActions.set_feedback_full:
      return {...action.submission as ISubmissionData};
    case SubmissionActions.set_feedback_header:
      return Object.assign({}, state, action.submission );
    case SubmissionActions.set_criteria:

      const local_rubric_row_feedback = tmpSubmission.submissionFeedback.rubric_row_feedbacks.find( candidate => candidate.criterium_id === action.rubric_row_feedback.criterium_id );
      Object.assign( local_rubric_row_feedback, action.rubric_row_feedback );
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
  submissionFeedback: ISubmissionFeedback;
}

type Props = {
};

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

  const [t, i18n] = useTranslation( `${category}s` );
  const [panels, setPanels] = useState( () => ['submissions'] )
  const [submissionsIndex, setSubmissionsIndex] = useState( Array<ISubmissionCondensed> );
  const [assignmentAcceptsText, setAssignmentAcceptsText] = useState( false );
  const [assignmentAcceptsLink, setAssignmentAcceptsLink] = useState( false );
  const [assignmentGroupEnabled, setAssignmentGroupEnabled] = useState( false );

  const [selectedSubmission, updateSelectedSubmission] = useReducer(SubmissionReducer, {} );

  const columns: GridColDef[] = [
    { field: "recordedScore", headerName: t("submissions.score") },
    { field: "submitted", headerName: t("submissions.submitted") },
    { field: "withdrawn", headerName: t("submissions.withdrawn") },
    {
      field: "user",
      headerName: t("submissions.submitter"),
      renderCell: (params: GridRenderCellParams) =>{
          return `${params.value.last_name}, ${params.value.first_name}`;
      }
    },
  ];

  //Retrieve the submission
  const loadSubmission = (submissionId:number) => {
    dispatch( startTask());
    const url = `${endpoints.showUrl}${submissionId}.json`;
    axios.get( url )
      .then(response => {
        const data = response.data as {
          submission: ISubmissionData,
          submission_feedback: ISubmissionFeedback,
          rubric: IRubricData
        };
        console.log( data.submission );
        if( data.submission_feedback === undefined ){
          data.submission_feedback = genCleanFeedback( data.submission.id, data.submission.rubric );
        }

        updateSelectedSubmission({type: SubmissionActions.set_feedback_full, submission: data.submission} );

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
        console.log( data.assignment );
        setAssignmentAcceptsText( data.assignment.text_sub );
        setAssignmentAcceptsLink( data.assignment.link_sub );
        setAssignmentGroupEnabled( data.assignment.group_enabled );
        setSubmissionsIndex( data.assignment.submissions );
        
      })
  }

  return (
    <>
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
              <DataGrid
                onRowClick={(params: GridRowParams) =>{
                  loadSubmission( params.row.id );
                }}
                getRowId={(model: GridRowModel) => {
                  return model.id;
                }}
                autoHeight
                rows={submissionsIndex}
                columns={columns}
                isCellEditable={params => {
                  return false;
                }}
                onCellClick={(params, event, details) => {
                    //navigate(String(params.row.id));
                }}
                slots={{
                  //Toolbar: AdminListToolbar
                }}
                slotProps={{
                  toolbar: {
                    activityType: "submission"
                  }
                }}
              />

        </Grid>
      ): null}
      {panels.includes('submitted') ? (
        <Grid xs={12 / panels.length } >
          <Typography variant="h6">
            {t('submitted')}
          </Typography>
          {assignmentAcceptsLink ? <Link href={selectedSubmission.sub_link}>{selectedSubmission.sub_link}</Link> : null}
          {assignmentAcceptsText ? (
          <Typography>
            {parse( selectedSubmission.sub_text )}
          </Typography>
          ) : null }
        </Grid>
      ): null}
      {panels.includes('feedback') ? (
        <Grid xs={12 / panels.length } >
          <Typography variant="h6">
            {t('feedback')}
          </Typography>
          <RubricScorer submission={selectedSubmission} />
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

    
    </>

  );
}
export { ISubmissionData };