import React, { useState, useEffect } from "react";
import { useSelector, useDispatch } from 'react-redux';

import {acknowledgeMsg} from './infrastructure/StatusActions';

import Alert from "@material-ui/lab/Alert";
import IconButton from "@material-ui/core/IconButton";
import Collapse from "@material-ui/core/Collapse";
import WorkingIndicator from "./infrastructure/WorkingIndicator";

import CloseIcon from "@material-ui/icons/Close";

//import { useStatusStore } from "./infrastructure/StatusStore";

export default function AppStatusBar(props) {
  //const [status, statusActions] = useStatusStore();

  const messages = useSelector(state =>{ return state.statusMessages } );
  const dispatch = useDispatch( );

  return (
    <React.Fragment>
      {messages.map((message, index) => {
        return (
          <Collapse key={`collapse_${index}`} in={!message["dismissed"]}>
            <Alert
              id={`alert_${index}`}
              action={
                <IconButton
                  aria-label="close"
                  color="inherit"
                  size="small"
                  onClick={() => {
                    dispatch(acknowledgeMsg( index ));
                    //statusActions.acknowledge(index);
                  }}
                >
                  <CloseIcon fontSize="inherit" />
                </IconButton>
              }
            >
              {message["text"] || null}
            </Alert>
          </Collapse>
        );
      })}
      <WorkingIndicator />
    </React.Fragment>
  );
}
