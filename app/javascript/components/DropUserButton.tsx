import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import IconButton from "@material-ui/core/IconButton";
import LinearProgress from "@material-ui/core/LinearProgress";
import Paper from "@material-ui/core/Paper";
import Tooltip from "@material-ui/core/Tooltip";

import DeleteForeverIcon from "@material-ui/icons/DeleteForever";

import Dialog from "@material-ui/core/Dialog";
import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import { DialogActions, Button, Collapse } from "@material-ui/core";

export default function DropUserButton(props) {
  const [showDialog, setShowDialog] = useState(false);

  function PaperComponent(props) {
    return <Paper {...props} />;
  }

  const copyDialog = (
    <Dialog
      open={showDialog}
      onClose={(event, reason) => setShowDialog(false)}
      aria-labelledby="alert-delete-confirm"
      aria-describedby="alert-delete-confirm-description"
    >
      <DialogTitle id="alert-delete-confirm">
        {"Confirm dropping student from course"}
      </DialogTitle>
      <DialogContent>
        <DialogContentText id="alert-delete-confirm-description">
          Are you sure you want to drop this user from this course? This can be
          reversed later, but it may result in lost data and confusion on the
          part of the student.
        </DialogContentText>
      </DialogContent>
      <DialogActions>
        <Button onClick={event => setShowDialog(false)} color="primary">
          Cancel
        </Button>
        <Button
          onClick={event => {
            fetch(props.dropUrl, {
              method: "GET",
              credentials: "include",
              headers: {
                "Content-Type": "application/json",
                Accepts: "application/json",
                "X-CSRF-Token": props.token
              }
            })
              .then(response => {
                if (response.ok) {
                  return response.json();
                } else {
                  console.log("error");
                }
              })
              .then(data => {
                props.refreshFunc(data.messages);
                setShowDialog(false);
              });
          }}
          color="primary"
          autoFocus
        >
          Drop the Student
        </Button>
      </DialogActions>
    </Dialog>
  );

  return (
    <React.Fragment>
      <Tooltip key="delete-forever" title={"Drop Student"}>
        <IconButton
          aria-label={"Drop Student"}
          onClick={event => {
            setShowDialog(true);
          }}
        >
          <DeleteForeverIcon />
        </IconButton>
      </Tooltip>
      {copyDialog}
    </React.Fragment>
  );
}

DropUserButton.propTypes = {
  token: PropTypes.string.isRequired,
  dropUrl: PropTypes.string.isRequired,
  refreshFunc: PropTypes.func.isRequired
};
