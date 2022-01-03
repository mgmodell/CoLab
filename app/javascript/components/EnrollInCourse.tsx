import React, { useState, useEffect } from "react";
import { useHistory } from "react-router-dom";
//Redux store stuff
import { useSelector, useDispatch } from 'react-redux';
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  acknowledgeMsg} from './infrastructure/StatusActions';
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";

import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import { useTranslation } from 'react-i18next';
import Grid from "@material-ui/core/Grid";
import Paper from "@material-ui/core/Paper";
import {useTypedSelector} from './infrastructure/AppReducers'
import axios from "axios";

export default function EnrollInCourse(props) {

  const category = 'home';
  const dispatch = useDispatch( );
  const epts = useTypedSelector((state)=>state.context.endpoints);
  const endpoints = useTypedSelector((state)=>state.context.endpoints[category]);
  const endpointsLoaded = useTypedSelector(state=>state.context.status.endpointsLoaded );
  const [t, i18n] = useTranslation( category );
  const history = useHistory( );

  const [courseName, setCourseName] = useState( 'loading' );
  const [courseNumber, setCourseNumber] = useState( 'loading' );

  const [enrollable, setEnrollable] = useState( false );
  const [messageHeader, setMessageHeader] = useState( 'Enrollment' );
  const [message, setMessage] = useState( 'Loading...' );


  const enrollConfirm = (confirm:boolean) => {
    if( confirm ){
      const url = `${endpoints.selfRegUrl}/${props.courseId}.json`;
      axios.post( url, {} )
        .then( response =>{
          // Success!
        })
        .catch( error =>{
          console.log( 'error', error );
        })
    }
    history.push( '/' );
  }

  const enrollButton =  (
    <Button disabled={!endpointsLoaded || !enrollable} variant="contained" onClick={()=>{
      enrollConfirm( true );
    }}>
      {t('self_enroll')}
    </Button>
  );
  const cancelButton =  (
    <Button variant="contained" onClick={()=>{
      enrollConfirm( true );
    }}>
      {t('self_enroll_cancel')}
    </Button>
  );


  useEffect(() =>{
    if( endpointsLoaded ){
      const url = `${endpoints.selfRegUrl}/${props.courseId}.json`;
      dispatch( startTask( ) );
      axios.get( url, { } )
        .then( response =>{
          console.log( 'response', response );
          const data = response.data;
          setCourseName( data.course.name );
          setCourseNumber( data.course.number );
          setEnrollable( data.enrollable );
          setMessageHeader( data.message_header );
          setMessage( data.message );
        })
        .catch( error =>{
          console.log( 'error', error );
        })
        .finally( () =>{
          dispatch( endTask ( ) );
        })
    }
  },[endpointsLoaded])


  return (
    <Paper>
      
      <h1>{t(messageHeader)}</h1>
      <p>
        {t(message,
        {
          course_name: courseName,
          course_number: courseNumber
        })}
      </p>
      <Grid container>
        <Grid item xs={12} sm={6} >
          {enrollButton}
        </Grid>
        <Grid item xs={12} sm={6}>
          {cancelButton}
        </Grid>
      </Grid>
    </Paper>
  );
}
EnrollInCourse.propTypes = {
  courseId: PropTypes.number.isRequired
}
