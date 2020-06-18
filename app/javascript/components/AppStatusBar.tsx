import React, { useState, useEffect } from "react";

import Alert from "@material-ui/lab/Alert";
import IconButton from '@material-ui/core/IconButton';
import Collapse from "@material-ui/core/Collapse";
import WorkingIndicator from './infrastructure/WorkingIndicator';

import CloseIcon from "@material-ui/icons/Close";

import { useStatusStore } from './infrastructure/StatusStore';

export default function Quote(props) {
  const [status, statusActions] = useStatusStore( );

  return (
    <React.Fragment>
      { status.statusMessages.map( (message, index)  =>{
        return(
          <Collapse key={`collapse_${index}`} in={ !status.message['dismissed'] }>
            <Alert
              id={`alert_${index}`}
              action={
                <IconButton
                  aria-label="close"
                  color="inherit"
                  size="small"
                  onClick={() => {
                    statusActions.acknowledge(index);
                  }}
                >
                  <CloseIcon fontSize="inherit" />
                </IconButton>
              }
            >
              {message['text'] || null}
            </Alert>
          </Collapse>
        )
      } ) }
      <WorkingIndicator />
    </React.Fragment>
  );
}
