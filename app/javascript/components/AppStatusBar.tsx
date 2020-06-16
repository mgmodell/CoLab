import React, { useState, useEffect } from "react";

import Alert from "@material-ui/lab/Alert";
import IconButton from '@material-ui/core/IconButton';
import Collapse from "@material-ui/core/Collapse";
import LinearProgress from '@material-ui/core/LinearProgress';

import CloseIcon from "@material-ui/icons/Close";

import { useStatusStore } from './infrastructure/StatusStore';

export default function Quote(props) {
  const [status, statusActions] = useStatusStore( );

  return (
    <React.Fragment>
      { status.statusMessages.map( (message, index)  =>{
        return(
          <Collapse in={ !status.message['dismissed'] }>
            <Alert
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
      {status.working ? <LinearProgress id='waiting' /> : null}
    </React.Fragment>
  );
}
