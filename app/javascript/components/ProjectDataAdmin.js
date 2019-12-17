import React, { useState, useEffect } from "react"
import PropTypes from "prop-types"
import LinearProgress from '@material-ui/core/LinearProgress';
import TextField from '@material-ui/core/TextField';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Switch from '@material-ui/core/Switch';
import Paper from '@material-ui/core/Paper';
import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from '@material-ui/pickers'

import LuxonUtils from '@date-io/luxon'
import { useUserStore } from './UserStore';

export default function ProjectDataAdmin( props ){
  const [dirty, setDirty] = useState( false );
  const [working, setWorking] = useState( true );
  const [factorPacks, setFactorPacks] = useState( [ ] );
  const [styles, setStyles] = useState( [ ] );
  const [project, setProject] = useState( { id: props.projectId } );
  const [user, userActions] = useUserStore( );

  const getProject = ()=>{
    setDirty( true );
    const url= props.url + '/' + project.id + '.json';
    fetch( url, {
      method: 'GET',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        Accepts: 'application/json',
        'X-CSRF-Token': props.token
      }
    })
    .then( response => {
      if( response.ok ){
        return response.json( );
      } else {
        console.log( 'error' );
      }
    })
    .then( data => {
      setFactorPacks( data.factorPacks );
      setStyles( data.styles );
      setProject( data.project );
      setWorking( false );
      setDirty( false );
    } );

  }
  useEffect( ()=>{
    if( !user.loaded ){
      userActions.fetch( props.token );
    }
    getProject( );
  }, [] )

  const toggleChecked = ( ) => {

  }

    return (
      <Paper>
        { working ? 
          <LinearProgress /> :
          null }
          <TextField
            label='Project Name'
            value={project.name}
            fullWidth={true}
            onChange={(event)=>handleChange( event, 'name' )} />
          <TextField
            label='Project Description'
            value={project.description}
            fullWidth={true}
            onChange={(event)=>handleChange( event, 'description' )} />
          <FormControlLabel
            control={
              <Switch
                checked={project.active}
                onChange={toggleChecked}
              />}
            label='Active' />
        
        <MuiPickersUtilsProvider utils={LuxonUtils}>
          <KeyboardDatePicker
            disableToolbar
            variant='inline'
            format='MM/dd/yyyy'
            margin='normal'
            label='Project Start Date'
            value={project.start_date}
            onChange={(event)=>handleDateChange( event, 'start' )}
          />
          <KeyboardDatePicker
            disableToolbar
            variant='inline'
            format='MM/dd/yyyy'
            margin='normal'
            label='Project End Date'
            value={project.start_date}
            onChange={(event)=>handleDateChange( event, 'start' )}
          />
        </MuiPickersUtilsProvider>
      </Paper>
    );
}

ProjectDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  projectId: PropTypes.number,
  projectUrl: PropTypes.string.isRequired,
  activateProjectUrl: PropTypes.string.isRequired,
};
