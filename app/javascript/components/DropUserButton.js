import React, { useState } from "react";
import PropTypes from "prop-types";
import IconButton from "@mui/material/IconButton";
import Paper from "@mui/material/Paper";
import Tooltip from "@mui/material/Tooltip";

import DeleteForeverIcon from "@mui/icons-material/DeleteForever";

import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import { DialogActions, Button, Collapse } from "@mui/material";
import axios from "axios";

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
            axios
              .get(props.dropUrl, {})
              .then(response => {
                const data = response.data;
                props.refreshFunc(data.messages);
                setShowDialog(false);
              })
              .catch(error => {
                console.log("error", error);
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
          size="large"
        >
          <DeleteForeverIcon />
        </IconButton>
      </Tooltip>
      {copyDialog}
    </React.Fragment>
  );
}

DropUserButton.propTypes = {
  dropUrl: PropTypes.string.isRequired,
  refreshFunc: PropTypes.func.isRequired
};
