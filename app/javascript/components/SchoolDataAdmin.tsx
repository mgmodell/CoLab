import React, { useState, useEffect } from "react";
//Redux store stuff
import { useDispatch } from 'react-redux';
import {
  startTask,
  endTask,
  addMessage,
  Priorities,
  setDirty,
  setClean
      } from './infrastructure/StatusActions';
import { useParams } from "react-router-dom";
import Button from "@material-ui/core/Button";
import TextField from "@material-ui/core/TextField";
import InputLabel from "@material-ui/core/InputLabel";
import FormControl from "@material-ui/core/FormControl";
import Select from "@material-ui/core/Select";
import Paper from "@material-ui/core/Paper";
import MenuItem from "@material-ui/core/MenuItem";
import FormHelperText from "@material-ui/core/FormHelperText";

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { TextareaAutosize } from "@material-ui/core";
import { useTypedSelector } from "./infrastructure/AppReducers";
import axios from "axios";

export default function SchoolDataAdmin(props) {
  const category = "school";
  const endpoints = useTypedSelector( state => {return state.context.endpoints[category]})
  const endpointStatus = useTypedSelector( state => {return state.context.status.endpointsLoaded})
  //const { t, i18n } = useTranslation('schools' );
  const user = useTypedSelector(state=>state.profile.user );
  const userLoaded = useTypedSelector(state=>{ return (null != state.profile.lastRetrieved) } );

  const dirty = useTypedSelector(state=>{ return (state.status.dirtyStatus['endpointSet']) } );

  const dispatch = useDispatch( );


  let {id} = useParams( );
  const [schoolId, setSchoolId] = useState( id );
  const [schoolName, setSchoolName] = useState("");
  const [schoolDescription, setSchoolDescription] = useState("");
  const [schoolTimezone, setSchoolTimezone] = useState("UTC");
  const [messages, setMessages] = useState( { } );

  const timezones = useTypedSelector( state => {return state.context.lookups['timezones'] })

  const getSchool = () => {
    dispatch( startTask() );
    var url = endpoints.baseUrl + "/";
    if (null == schoolId) {
      url = url + "new.json";
    } else {
      url = url + schoolId + ".json";
    }
    axios.get( url, { } )
      .then( (response) =>{
        const school = response.data.school;

        setSchoolName(school.name || "");
        setSchoolDescription(school.description || "");
        setSchoolTimezone(school.timezone || "UTC");


      } )
      .catch( error => {
        console.log( 'error', error )
      })
      .finally(()=>{
        dispatch( endTask() );
        dispatch( setClean( category ) );
      })
  };
  const saveSchool = () => {
    const method = null == schoolId ? "POST" : "PATCH";
    dispatch( startTask("saving") );

    const url =
      endpoints['baseUrl'] +
      "/" +
      (null == schoolId ? props.schoolId : schoolId) +
      ".json";

    axios({
      method: method,
      url: url,
      data: {
        school: {
          name: schoolName,
          description: schoolDescription,
          timezone: schoolTimezone
        }
      }
    })
      .then(resp => {
        const data = resp['data'];
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const school = data.school;
          setSchoolId(school.id);
          setSchoolName(school.name);
          setSchoolDescription(school.description);
          setSchoolTimezone(school.timezone);

          dispatch( setClean( category ) );
          dispatch( addMessage( data.messages.main, new Date( ), Priorities.INFO ) );
          //setMessages(data.messages);
          dispatch( endTask("saving") );
        } else {
          dispatch( addMessage( data.messages.main, new Date( ), Priorities.ERROR ) );
          setMessages(data.messages);
          dispatch( endTask("saving") );
        }
      })
      .catch( error => {
        console.log( 'error', error )
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getSchool();
    }
  }, [endpointStatus]);

  useEffect(() => {
    if (userLoaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [userLoaded]);

  useEffect(() => {
    dispatch( setDirty( category ) );
  }, [
    schoolTimezone,
    schoolName,
    schoolDescription
  ]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveSchool} disabled={!dirty} >
      {schoolId > 0 ? 'Save' : 'Create'} School
    </Button>
  ) : null;

  const detailsComponent = endpointStatus ? (
    <Paper>
      <TextField
        label="School Name"
        id="school-name"
        value={schoolName}
        fullWidth={false}
        onChange={event => setSchoolName(event.target.value)}
        error={null != messages["name"]}
        helperText={messages["name"]}
      />
      &nbsp;
      <FormControl>
        <InputLabel htmlFor="school_timezone" id="school_timezone_lbl">
          Time Zone
        </InputLabel>
        <Select
          id="school_timezone"
          value={schoolTimezone}
          onChange={event => setSchoolTimezone(String(event.target.value))}
        >
          {timezones.map(timezone => {
            return (
              <MenuItem key={timezone.name} value={timezone.name}>
                {timezone.name}
              </MenuItem>
            );
          })}
        </Select>
        <FormHelperText error={true}>{messages["timezone"]}</FormHelperText>
      </FormControl>
      <br />
      <TextField
        id="school-description"
        placeholder="Enter a description of the school"
        multiline={true}
        minRows={2}
        maxRows={4}
        label="Description"
        value={schoolDescription}
        onChange={event => setSchoolDescription(event.target.value)}
        InputLabelProps={{
          shrink: true
        }}
        margin="normal"
      />
      <br />
      {saveButton}
    </Paper>
  ) : null;

  return (
    <Paper>
      {detailsComponent}
    </Paper>
  );
}
