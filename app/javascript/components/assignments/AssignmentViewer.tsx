import React, { Suspense, useState, useEffect, useReducer } from "react";
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

import RubricViewer, { CLEAN_RUBRIC } from "./RubricViewer";
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
import AssignmentSubmission from "./AssignmentSubmission";

interface ISubmissionCondensed {
  id: number;
  recordedScore: number;
  submitted: DateTime;
  withdrawn: DateTime;
  user: string;
  group: string;
}

interface IAssignment {
  id: number|null,
  name: string;
  description: string;
  startDate: DateTime;
  endDate: DateTime;
  textSub: boolean;
  linkSub: boolean;
  fileSub: boolean;
  submissions: Array<ISubmissionCondensed>;
  rubric: IRubricData;
}

const CLEAN_ASSIGNMENT: IAssignment = {
  id: null,
  name: '',
  description: '',
  startDate: DateTime.local( ),
  endDate: DateTime.local( ),
  textSub: false,
  linkSub: false,
  fileSub: false,
  submissions: [],
  rubric: CLEAN_RUBRIC
}


export default function AssignmentViewer(props) {
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

  const [submissions, setSubmissions] = useState( [] );

  enum AssignmentActions{
    setAssignment = 'SET ASSIGNMENT',
    setValue = 'SET VALUE'
  }
  
  const assignmentReducer = (state, action) =>{
    switch(action.type){
      case AssignmentActions.setAssignment:
        return {...action.assignment as IAssignment};
      case AssignmentActions.setValue:
        return {...state, [action.field]: action.value};
      default:
        throw new Error();
    }
  };
  const [assignment, modifyAssignment] = React.useReducer( assignmentReducer, CLEAN_ASSIGNMENT );

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

        //Process, clean and set the data received
        const receivedAssignment:IAssignment = {...data.assignment};
        let receivedDate = DateTime.fromISO( data.assignment.start_date ).setZone( Settings.timezone );
        receivedAssignment.startDate = receivedDate;
        receivedDate = DateTime.fromISO( data.assignment.end_date ).setZone( Settings.timezone );
        receivedAssignment.endDate = receivedDate;
        receivedAssignment.rubric = data.rubric;
        receivedAssignment.submissions = data.submissions;
        //Convert snake- to camel-case properties
        receivedAssignment.textSub = receivedAssignment.text_sub;
        delete receivedAssignment.text_sub;
        receivedAssignment.fileSub = receivedAssignment.file_sub;
        delete receivedAssignment.file_sub;
        receivedAssignment.linkSub = receivedAssignment.link_sub;
        delete receivedAssignment.link_sub;

        modifyAssignment({
          type: AssignmentActions.setAssignment,
          assignment: receivedAssignment });
        
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(()=>{
        dispatch(endTask());
      })
      ;
  };

  const handleTabChange = (event: React.SyntheticEvent, newTab: string ) =>{
    setCurTab( newTab );
  }

  let output = null;
  const curDate = new Date();
  console.log( assignment, curDate,
    assignment.startDate > curDate ? 'true' : 'false',
    assignment.endDate < curDate ? 'true' : 'false'
    );
  if (!endpointsLoaded) {
    output = ( <Skeleton variant="rectangular" /> );
  } else {
    output = (
      <TabContext value={curTab}>
        <TabList onChange={handleTabChange} >
          <Tab label='Overview' value='overview' />
          <Tab label='Responses' value='responses' disabled={
            assignment.startDate > curDate || assignment.endDate < curDate
            } />
          <Tab label='Progress' value='progress' disabled={submissions.length < 1 || assignment.startDate < curDate} />
        </TabList>
        <TabPanel value='overview'>
          <Grid container spacing={1} columns={70}>
            <Grid item xs={15}>
              <Typography variant="h6">{t('name' )}:</Typography>
            </Grid>
            <Grid item xs={55}>
              <Typography>
                {assignment.name}
              </Typography>
            </Grid>
            <Grid item xs={15}>
              <Typography variant="h6">{t('status.brief')}:</Typography>
            </Grid>
            <Grid>
              {parse(assignment.description)}
            </Grid>
            <Grid item xs={70}>
              <Typography variant="h6">
                {t('status.eval_criteria')}:
              </Typography>
            </Grid>
            <RubricViewer rubric={assignment.rubric } />
          </Grid>
        </TabPanel>
        <TabPanel value='responses'>
          <AssignmentSubmission
            assignment={assignment}
            reloadCallback={loadAssignment}
            />
        </TabPanel>
        <TabPanel value='progress'>
          Working on it
        </TabPanel>
      </TabContext>

    );
  }

  return output;
};

export {IAssignment, ISubmissionCondensed, CLEAN_ASSIGNMENT};