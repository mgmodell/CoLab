import React, { useState } from "react";
import axios from "axios";
import { useDispatch } from "react-redux";
import PropTypes from "prop-types";
import IconButton from "@mui/material/IconButton";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Tooltip from "@mui/material/Tooltip";
import TextField from "@mui/material/TextField";
import { DateTime } from "luxon";
import DatePicker from "@mui/lab/DatePicker";
import LocalizationProvider from "@mui/lab/LocalizationProvider";
import AdapterLuxon from "@mui/lab/AdapterLuxon";

import CollectionsBookmarkIcon from "@mui/icons-material/CollectionsBookmark";

import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import DialogActions from "@mui/material/DialogActions";
import Button from "@mui/material/Button";

import { startTask, endTask } from "./infrastructure/StatusActions";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { useTranslation } from 'react-i18next';

export default function CopyActivityButton(props) {
  const category = "course";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const status = useTypedSelector(
    state=> state.status.tasks
  );
  const{ t } = useTranslation( category );
  const dispatch = useDispatch();

  const [copyData, setCopyData] = useState(null);
  const [newStartDate, setNewStartDate] = useState(DateTime.local().toISO());
  const [value, setValue] = useState(null);

  const copyDialog = (
    <Dialog
      open={null != copyData}
      onClose={(event, reason) => {
        setNewStartDate(null);
        setCopyData(null);
      }}
    >
      {null != copyData ? (
        <React.Fragment>
          <LocalizationProvider dateAdapter={AdapterLuxon}>
            <DialogTitle>{t('Dialog_Title')}</DialogTitle>
            <DialogContent>
              <WorkingIndicator identifier="copying_course" />
              <DialogContentText>
                This course started on{" "}
                {props.startDate.toLocaleString(DateTime.DATE_SHORT)}. When
                would you like for the new copy to begin? Everything will be
                shifted accordingly.
                <br />
              </DialogContentText>
              <DatePicker
                variant="inline"
                autoOk={true}
                inputFormat="MM/dd/yyyy"
                margin="normal"
                id="newCourseStartDate"
                label={t('date_picker_label')}
                value={newStartDate}
                onChange={newValue => {
                  setNewStartDate(newValue);
                }}
                renderInput={props => <TextField {...props} />}
              />
            </DialogContent>
            <DialogActions>
              <Button
                disabled={status.working}
                onClick={event => {
                  setNewStartDate(DateTime.local().toISO());
                  setCopyData(null);
                }}
              >
                {t('copy_cancel_btn')}
              </Button>
              <Button
                disabled={status.working}
                onClick={event => {
                  dispatch(startTask("copying_course"));
                  const url = `${endpoints.courseCopyUrl}${props.itemId}.json`;

                  axios
                    .post(url, {
                      start_date: newStartDate
                    })
                    .then(response => {
                      const data = response.data;
                      props.addMessagesFunc(data.messages);
                      if (Boolean(props.itemUpdateFunc)) {
                        props.itemUpdateFunc();
                      }
                      setNewStartDate(DateTime.local().toISO());
                      setCopyData(null);
                      dispatch(endTask("copying_course"));
                    })
                    .catch(error => {
                      console.log("error:", error);

                      dispatch(endTask("copying"));
                    });
                }}
              >
                {t('copy_btn_aria')}
              </Button>
            </DialogActions>
          </LocalizationProvider>
        </React.Fragment>
      ) : (
        <DialogContent />
      )}
    </Dialog>
  );

  return (
    <React.Fragment>
      <Tooltip title={t('btn_tooltip_title')} aria-label="Copy">
        <IconButton
          id={"copy-" + props.itemId}
          onClick={event => {
            setCopyData({
              id: props.itemId,
              startDate: props.startDate,
              copyUrl: props.copyUrl + props.itemId + ".json"
            });
          }}
          aria-label={t('aria_label_btn')}
          size={t('size_btn')}
        >
          <CollectionsBookmarkIcon />
        </IconButton>
      </Tooltip>
      {copyDialog}
    </React.Fragment>
  );
}

CopyActivityButton.propTypes = {
  itemId: PropTypes.number.isRequired,
  itemUpdateFunc: PropTypes.func,
  startDate: PropTypes.instanceOf(Date).isRequired,
  addMessagesFunc: PropTypes.func.isRequired
};
