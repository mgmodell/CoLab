import React from "react"
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

class ProjectDataAdmin extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      dirty: false,
      working: true,
      project: {
        name: '',
      },
      factor_packs: [ ],
      styles: [ ]
    }
  }

  componentDidMount( ){
    //TODO: do that fetching thing

  }

  toggleChecked( ){

  }

  render () {
    return (
      <Paper>
        { this.state.working ? 
          <LinearProgress /> :
          null }
          <TextField
            label='Project Name'
            value={this.state.project.name}
            fullWidth={true}
            onChange={(event)=>handleChange( event, 'name' )} />
          <TextField
            label='Project Description'
            value={this.state.project.desscription}
            fullWidth={true}
            onChange={(event)=>handleChange( event, 'description' )} />
          <FormControlLabel
            control={
              <Switch
                checked={this.state.active}
                onChange={this.toggleChecked}
              />}
            label='Active' />
        
        <MuiPickersUtilsProvider utils={LuxonUtils}>
          <KeyboardDatePicker
            disableToolbar
            variant='inline'
            format='MM/dd/yyyy'
            margin='normal'
            label='Project Start Date'
            value={this.state.project.start_date}
            onChange={(event)=>handleDateChange( event, 'start' )}
          />
          <KeyboardDatePicker
            disableToolbar
            variant='inline'
            format='MM/dd/yyyy'
            margin='normal'
            label='Project End Date'
            value={this.state.project.start_date}
            onChange={(event)=>handleDateChange( event, 'start' )}
          />
        </MuiPickersUtilsProvider>
      </Paper>
    );
  }
}

ProjectDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  projectId: PropTypes.number,
  projectUrl: PropTypes.string.isRequired,
  activateProjectUrl: PropTypes.string.isRequired,
};
export default ProjectDataAdmin
