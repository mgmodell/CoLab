import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import IconButton from '@material-ui/core/IconButton';
import LinearProgress from "@material-ui/core/LinearProgress";
import Paper from '@material-ui/core/Paper';
import Tooltip from '@material-ui/core/Tooltip'
import {DateTime} from 'luxon'
import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from "@material-ui/pickers";
import LuxonUtils from '@date-io/luxon';


import CollectionsBookmarkIcon from '@material-ui/icons/CollectionsBookmark';

import Dialog from "@material-ui/core/Dialog";
import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import { DialogActions, Button, Collapse } from "@material-ui/core";

export default function CopyActivityButton(props) {
  const [copyData, setCopyData] = useState( null );

  function PaperComponent(props) {
    return (
        <Paper {...props} />
    );
  }

  const [newStartDate, setNewStartDate] = useState( DateTime.local().toISO() );

  const copyDialog = (
                       <Dialog
                         open={null != copyData}
                         PaperComponent={PaperComponent}
                         onClose={(event,reason)=>{
                           setNewStartDate( DateTime.local().toISO( ) )
                           setNewStartDate( null )
                           setCopyData( null )
                         }}
                         >
                           {null != copyData ? (
                             <React.Fragment>

                              <DialogTitle>Create a Copy</DialogTitle>
                              <DialogContent>
                                {props.isWorking ? <LinearProgress/> : null }
                                <DialogContentText>
                                  This course started on {copyData.startDate.toLocaleString(DateTime.DATE_SHORT)}.
                                  When would you like for the new copy to begin? Everything will be shifted accordingly.
                                  <br/>

                                </DialogContentText>
                                 <MuiPickersUtilsProvider utils={LuxonUtils}>
                                   <KeyboardDatePicker
                                     variant='inline'
                                     autoOk={true}
                                     format="MM/dd/yyyy"
                                     margin='normal'
                                     id='newCourseStartDate'
                                     label="New course start date?"
                                     value={newStartDate}
                                     onChange={setNewStartDate}
                                   />
                                  </MuiPickersUtilsProvider>
                              </DialogContent>
                              <DialogActions>
                                <Button disabled={props.isWorking} onClick={(event)=>{
                                    setNewStartDate( DateTime.local().toISO( ) );
                                    setNewStartDate( null );
                                    setCopyData(null)
                                  }}
                                  >
                                  Cancel
                                </Button>
                                <Button disabled={props.isWorking} onClick={(event)=>{
                                  props.setIsWorking( true );
                                  console.log( newStartDate );
                                  fetch( props.copyUrl ,{
                                    method: 'POST',
                                    credentials: 'include',
                                    headers: {
                                      'Content-Type': 'application/json',
                                      Accepts: 'application/json',
                                      'X-CSRF-Token': props.token
                                    },
                                    body: JSON.stringify({
                                      start_date: newStartDate
                                    })
                                  })
                                  .then(response=>{
                                    if( response.ok ){
                                      return response.json()
                                    }else{
                                      console.log( 'Error' )
                                    }
                                  })
                                  .then(data =>{
                                      props.addMessagesFunc( data.messages )
                                      if( Boolean( props.itemUpdateFunc ) ){
                                        props.itemUpdateFunc( );
                                      }
                                      setNewStartDate( DateTime.local().toISO( ) )
                                      setCopyData( null );
                                      props.setIsWorking( false );
                                  })
                                }}
                                >
                                  Make a Copy
                                </Button>
                              </DialogActions> 
                             </React.Fragment> ) : <DialogContent></DialogContent> }
                       </Dialog> )



  return (
    <React.Fragment>
      <Tooltip title="Create a copy based on this course" aria-label="Copy">
        <IconButton
          id={'copy-' + props.itemId }
          onClick={event=>{
            setCopyData( {
              id: props.itemId,
              startDate: props.startDate,
              copyUrl: props.copyUrl + props.itemId + '.json'
            } );
          }}
          aria-label='Make a Copy'>
            <CollectionsBookmarkIcon/>
        </IconButton>
      </Tooltip>
        {copyDialog}
    </React.Fragment>
  );
}

CopyActivityButton.propTypes = {
  token: PropTypes.string.isRequired,
  copyUrl: PropTypes.string.isRequired,
  itemId: PropTypes.number.isRequired,
  itemUpdateFunc: PropTypes.func,
  startDate: PropTypes.instanceOf(Date).isRequired,
  isWorking: PropTypes.bool.isRequired,
  setIsWorking: PropTypes.func.isRequired,
  addMessagesFunc: PropTypes.func.isRequired
};
