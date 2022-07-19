import React from "react";
import { useDispatch } from "react-redux";
import { useTypedSelector } from "./infrastructure/AppReducers";

import { acknowledgeMsg } from "./infrastructure/StatusActions";

import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import Collapse from "@mui/material/Collapse";
import WorkingIndicator from "./infrastructure/WorkingIndicator";

import CloseIcon from "@mui/icons-material/Close";

export default function AppStatusBar(props) {
  const messages = useTypedSelector(state => {
    return state.status.messages;
  });
  const dispatch = useDispatch();

  return (
    <React.Fragment>
      {messages.map((message, index) => {
        return (
          <Collapse key={`collapse_${index}`} in={!message["dismissed"]}>
            <Alert
              severity={message.priority}
              id={`alert_${index}`}
              action={
                <IconButton
                  aria-label={`${message.priority}-close`}
                  id={`${message.priority}-close`}
                  color="inherit"
                  size="small"
                  onClick={() => {
                    dispatch(acknowledgeMsg(index));
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
