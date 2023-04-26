import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useNavigate } from "react-router-dom";

//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  setClean,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";

import RubricViewer from "./RubricViewer";
import { IRubricData } from "./RubricViewer";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import { DateTime, Settings } from 'luxon';
import parse from 'html-react-parser';

import { useTranslation } from "react-i18next";
import Skeleton from "@mui/material/Skeleton";
import { TabContext, TabList, TabPanel } from "@mui/lab";
import Tab from "@mui/material/Tab";
import { Grid, Typography } from "@mui/material";

import { EditorState, convertToRaw, ContentState } from "draft-js";
const Editor = React.lazy(() => import("../reactDraftWysiwygEditor"));


export default function AssignmentSubmission(props) {
  const endpointSet = "assignment";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const { assignmentId } = useParams();

  const dispatch = useDispatch();
  const [t, i18n] = useTranslation( `${endpointSet}s` );
  const navigate = useNavigate();

  const [curTab, setCurTab] = useState( 'overview' );

  const [name, setName] = useState( '' );
  const [description, setDescription] = useState( '' );
  const [startDate, setStartDate] = useState( DateTime.local( ) );
  const [endDate, setEndDate] = useState( DateTime.local( ) );
  const [textSub, setTextSub] = useState( false );
  const [linkSub, setLinkSub] = useState( false );
  const [fileSub, setFileSub] = useState( false );

  const [submissions, setSubmissions] = useState( [] );

  const [rubric, setRubric ] = useState<IRubricData>( )

  useEffect(() => {
    if (endpointsLoaded) {
      loadAssignment();
    }
  }, [endpointsLoaded]);


  //Retrieve the latest data
  const loadAssignment = () => {
    const url = `${endpoints.statusUrl}${assignmentId}.json`;
    dispatch(startTask());
    axios(url, {})
      .then(response => {
        const data = response.data;

        //Set the data received
        setName( data.assignment.name );
        setDescription( data.assignment.description );

        let receivedDate = DateTime.fromISO( data.assignment.start_date ).setZone( Settings.timezone );
        setStartDate( receivedDate );
        receivedDate = DateTime.fromISO( data.assignment.end_date ).setZone( Settings.timezone );
        setEndDate( receivedDate );
        
        setTextSub( data.assignment.text_sub );
        setLinkSub( data.assignment.link_sub );
        setFileSub( data.assignment.file_sub );
        
        setRubric( data.rubric as IRubricData );
        setSubmissions( data.submissions );

        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  const handleTabChange = (event: React.SyntheticEvent, newTab: string ) =>{
    setCurTab( newTab );
  }

  let output = null;
  if (!endpointsLoaded) {
    output = ( <Skeleton variant="rectangular" /> );
  } else {
    output = (
      <TabContext value={curTab}>
        <TabList onChange={handleTabChange} >
          <Tab label='Overview' value='overview' />
          <Tab label='Responses' value='responses' />
          <Tab label='Progress' value='progress' disabled={submissions.length < 1} />
        </TabList>
        <TabPanel value='overview'>
          <Grid container spacing={1} columns={70}>
            <Grid item xs={15}>
              <Typography variant="h6">{t('name' )}:</Typography>
            </Grid>
            <Grid item xs={55}>
              <Typography>
                {name}
              </Typography>
            </Grid>
            <Grid item xs={15}>
              <Typography variant="h6">{t('status.brief')}:</Typography>
            </Grid>
            <Grid>
              {parse(description)}
            </Grid>
            <Grid item xs={70}>
              <Typography variant="h6">
                {t('status.eval_criteria')}:
              </Typography>
            </Grid>
            <RubricViewer rubric={rubric } />
          </Grid>
        </TabPanel>
        <TabPanel value='responses'>
          Working on it
        </TabPanel>
        <TabPanel value='progress'>
          Working on it
        </TabPanel>
      </TabContext>

    );
  }

  return output;
}

AssignmentSubmission.propTypes = {};
