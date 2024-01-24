import React, { useState } from "react";

import IconButton from "@mui/material/IconButton";
import Tooltip from "@mui/material/Tooltip";

import DeleteForeverIcon from "@mui/icons-material/DeleteForever";

import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import { DialogActions, Button, Collapse } from "@mui/material";
import axios from "axios";
import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

type Props = {
  dropUrl: string;
  refreshFunc: (messages: {}) => void;
};

export default function DropUserButton(props: Props) {
  const [showDialog, setShowDialog] = useState(false);

  const category = "course";
  const { t } = useTranslation(`${category}s`);
  const dispatch = useDispatch();


  const copyDialog = (
    <Dialog
      open={showDialog}
      onClose={(event, reason) => setShowDialog(false)}
      aria-labelledby="alert-delete-confirm"
      aria-describedby="alert-delete-confirm-description"
    >
      <DialogTitle id="alert-delete-confirm">
        {t("drop_confirm_title")}
      </DialogTitle>
      <DialogContent>
        <DialogContentText id="alert-delete-confirm-description">
          {t("drop_student_confirm_dlg")}
        </DialogContentText>
      </DialogContent>
      <DialogActions>
        <Button onClick={event => setShowDialog(false)} color="primary">
          {t("drop_cancel_btn")}
        </Button>
        <Button
          onClick={event => {
            dispatch(startTask("dropping"));
            axios
              .get(`${props.dropUrl}.json`, {})
              .then(response => {
                const data = response.data;
                props.refreshFunc(data.messages);
                setShowDialog(false);
              })
              .catch(error => {
                console.log("error", error);
              })
              .finally(() => {
                dispatch(endTask("dropping"));
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
      <Tooltip key="delete-forever" title={t("drop_tooltip_title")}>
        <IconButton
          aria-label={t("drop_tooltip_aria")}
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
