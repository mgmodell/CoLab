import React, { useState } from "react";

import { Button } from "primereact/button";

import axios from "axios";
import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { Dialog } from "primereact/dialog";

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
      visible={showDialog}
      onHide={() => setShowDialog(false)}
      aria-labelledby="alert-delete-confirm"
      aria-describedby="alert-delete-confirm-description"
      footer={
        <>
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
        </>
      }
    >
      {t("drop_student_confirm_dlg")}
    </Dialog>
  );

  return (
    <React.Fragment>
      <Button
        className="pi pi-trash"
        tooltip={t("drop_tooltip_title")}
        onClick={event => {
          setShowDialog(true);
        }}
        size="small"
        aria-label="drop student"
      />
      {copyDialog}
    </React.Fragment>
  );
}
