import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";

//Redux store stuff
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { useDispatch } from "react-redux";
import { Allotment } from 'allotment';

import { useTranslation } from "react-i18next";
import { ToggleButton, ToggleButtonGroup, Typography } from "@mui/material";
import { IRubricData, ICriteria } from "./RubricViewer";
import { ISubmissionCondensed } from "./AssignmentViewer";
import { DataGrid, GridRowModel, GridColDef } from "@mui/x-data-grid";
import Grid from "@mui/material/Unstable_Grid2";

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
  const [submissions, setSubmissions] = useState( Array<ISubmissionCondensed> );

  const columns: GridColDef[] = [
    { field: "recordedScore", headerName: t("submissions.score") },
    { field: "submitted", headerName: t("submissions.submitted") },
    { field: "withdrawn", headerName: t("submissions.withdrawn") },
    { field: "user", headerName: t("submissions.submitter") },
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
        setSubmissions( data.submissions );
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
                getRowId={(model: GridRowModel) => {
                  return model.id;
                }}
                autoHeight
                rows={submissions}
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
          {t('error.not_loaded')}
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
