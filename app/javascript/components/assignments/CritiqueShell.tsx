import React, { Suspense, useState, useEffect } from "react";
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
import { DataGrid, GridRowModel, GridColDef, GridRowParams } from "@mui/x-data-grid";
import Grid from "@mui/material/Unstable_Grid2";
import {DateTime} from 'luxon';
import parse from 'html-react-parser';

interface ISubmissionData{
  id: number;
  recordedScore: number;
  submitted: DateTime;
  withdrawn: DateTime;
  sub_text: string;
  sub_link: string;
  rubric: IRubricData;
  feedback: IFeedback;
}

interface IFeedback{
  id: number;
  feedback: string;
  rows: Map<number,IRowFeedback>;
}

interface IRowFeedback{
  id: number;
  criterium_id: number;
  score: number;
  feedback: string;
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
  const [selectedSubmission, setSelectedSubmission] = useState <number|null> (  );
  const [assignmentAcceptsText, setAssignmentAcceptsText] = useState( false );
  const [assignmentAcceptsLink, setAssignmentAcceptsLink] = useState( false );
  const [assignmentGroupEnabled, setAssignmentGroupEnabled] = useState( false );

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

  const getSubmission = (submissionId:number) => {
    dispatch( startTask());
    const url = `${endpoints.showUrl}${submissionId}.json`;
    axios.get( url )
      .then(response => {
        const data = response.data;
        console.log( data.submission );
        setSelectedSubmission( data.submission );
        if( !panels.includes('submitted') ){
          const tmpPanels = [...panels, 'submitted'];
          setPanels( tmpPanels );
        }
      }).finally( () =>{
        dispatch( endTask() );
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
                  getSubmission( params.row.id );
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
                components={{
                  //Toolbar: AdminListToolbar
                }}
                componentsProps={{
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
          {t('error.not_loaded')}
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
