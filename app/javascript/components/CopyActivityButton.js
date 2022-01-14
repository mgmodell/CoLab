import React, { useState, useEffect } from "react";
import axios from "axios";
import {useDispatch} from 'react-redux';
import PropTypes from "prop-types";
import IconButton from "@mui/material/IconButton";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Paper from "@mui/material/Paper";
import Tooltip from "@mui/material/Tooltip";
import TextField from "@mui/material/TextField";
import { DateTime } from "luxon";
import { DatePicker, LocalizationProvider } from "@mui/lab/";
import AdapterLuxon from '@mui/lab/AdapterLuxon';

import CollectionsBookmarkIcon from "@mui/icons-material/CollectionsBookmark";

import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import DialogActions from "@mui/material/DialogActions";
import Button from "@mui/material/Button";
import Collapse from "@mui/material/Collapse";

import {startTask, endTask} from './infrastructure/StatusActions';

export default function CopyActivityButton(props) {
  const [copyData, setCopyData] = useState(null);
  const dispatch = useDispatch( );

  function PaperComponent(props) {
    return <Paper {...props} />;
  }

  const [newStartDate, setNewStartDate] = useState(DateTime.local().toISO());

  const copyDialog = (
    <Dialog
      open={null != copyData}
      PaperComponent={PaperComponent}
      onClose={(event, reason) => {
        setNewStartDate(DateTime.local().toISO());
        setNewStartDate(null);
        setCopyData(null);
      }}
    >
      {null != copyData ? (
        <React.Fragment>
          <DialogTitle>Create a Copy</DialogTitle>
          <DialogContent>
            <WorkingIndicator identifier="copying_course" />
            <DialogContentText>
              This course started on{" "}
              {copyData.startDate.toLocaleString(DateTime.DATE_SHORT)}. When
              would you like for the new copy to begin? Everything will be
              shifted accordingly.
              <br />
            </DialogContentText>
            <LocalizationProvider dateAdapter={AdapterLuxon}>
              <DatePicker
                variant="inline"
                autoOk={true}
                inputFormat="MM/dd/yyyy"
                margin="normal"
                id="newCourseStartDate"
                label="New course start date?"
                value={newStartDate}
                onChange={setNewStartDate}
                renderInput={props => <TextField {...props} />}
              />
            </LocalizationProvider>
          </DialogContent>
          <DialogActions>
            <Button
              disabled={status.working}
              onClick={event => {
                setNewStartDate(DateTime.local().toISO());
                setNewStartDate(null);
                setCopyData(null);
              }}
            >
              Cancel
            </Button>
            <Button
              disabled={status.working}
              onClick={event => {
                dispatch( startTask("copying") );
                console.log(newStartDate);
                axios.post( props.copyUrl,{
                  start_date: newStartDate,
                })
                  .then( response =>{
                    const data = response.data;
                    props.addMessagesFunc(data.messages);
                    if (Boolean(props.itemUpdateFunc)) {
                      props.itemUpdateFunc();
                    }
                    setNewStartDate(DateTime.local().toISO());
                    setCopyData(null);
                    dispatch( endTask("copying") );
                  })
                  .catch( error =>{
                    console.log( 'error:', error)

                    dispatch( endTask("copying") );
                  })
              }}
            >
              Make a Copy
            </Button>
          </DialogActions>
        </React.Fragment>
      ) : (
        <DialogContent />
      )}
    </Dialog>
  );

  return (
    <React.Fragment>
      <Tooltip title="Create a copy based on this course" aria-label="Copy">
        <IconButton
          id={"copy-" + props.itemId}
          onClick={event => {
            setCopyData({
              id: props.itemId,
              startDate: props.startDate,
              copyUrl: props.copyUrl + props.itemId + ".json"
            });
          }}
          aria-label="Make a Copy"
          size="large">
          <CollectionsBookmarkIcon />
        </IconButton>
      </Tooltip>
      {copyDialog}
    </React.Fragment>
  );
}

CopyActivityButton.propTypes = {
  copyUrl: PropTypes.string.isRequired,
  itemId: PropTypes.number.isRequired,
  itemUpdateFunc: PropTypes.func,
  startDate: PropTypes.instanceOf(Date).isRequired,
  addMessagesFunc: PropTypes.func.isRequired
};
