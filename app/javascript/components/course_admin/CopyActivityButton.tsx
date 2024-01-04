import React, { useState } from "react";
import axios from "axios";
import { useDispatch } from "react-redux";

import { DateTime } from "luxon";
import { Calendar } from "primereact/calendar";
import { Nullable } from "primereact/ts-helpers";

import { Dialog } from "primereact/dialog";

import { Button } from "primereact/button";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";
import WorkingIndicator from "../infrastructure/WorkingIndicator";

type Props = {
  itemId: number;
  itemUpdateFunc: () => void;
  startDate: Date;
  copyUrl: string;
  addMessagesFunc: (msgs: {}) => void;
};

export default function CopyActivityButton(props: Props) {
  const category = "course";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const status = useTypedSelector(state => state.status.tasks);
  const { t } = useTranslation(`${category}s`);
  const dispatch = useDispatch();

  const [copyData, setCopyData] = useState(null);
  const [newStartDate, setNewStartDate] = useState<Nullable<Date>>(new Date());

  const copyDialog = (
    <Dialog
      visible={null !== copyData}
      header={<h3>{t("dialog_title")}</h3>}
      draggable={false}
      onClick={event => {
        event.preventDefault();
      }}
      closeOnEscape={false}
      modal={true}
      onHide={() => {
        setNewStartDate(DateTime.local());
        setCopyData(null);
      }}
      footer={
        <>
          <Button
            disabled={status.working}
            onClick={event => {
              setNewStartDate(DateTime.local());
              setCopyData(null);
            }}
          >
            {t("copy_cancel_btn")}
          </Button>
          <Button
            disabled={status.working}
            onClick={event => {
              dispatch(startTask("copying_course"));
              const url = `${endpoints.courseCopyUrl}${props.itemId}.json`;
              const sendDate = DateTime.fromISO(
                newStartDate.toISOString().substring(0, 10),
                { zone: "UTC" }
              );

              axios
                .post(url, {
                  start_date: sendDate
                })
                .then(response => {
                  const data = response.data;
                  props.addMessagesFunc(data.messages);
                  if (Boolean(props.itemUpdateFunc)) {
                    props.itemUpdateFunc();
                  }
                  setNewStartDate(DateTime.local());
                  setCopyData(null);
                  dispatch(endTask("copying_course"));
                })
                .catch(error => {
                  console.log("error:", error);

                  dispatch(endTask("copying"));
                });
            }}
          >
            {t("copy_btn_txt")}
          </Button>
        </>
      }
    >
      This course started on{" "}
      {props.startDate.toLocaleString(DateTime.DATE_SHORT)}. When would you like
      for the new copy to begin? Everything will be shifted accordingly.
      <br />
      <span className="card flex justify-content-center">
        <Calendar
          value={newStartDate}
          id="newCourseStartDate"
          showIcon
          onChange={newValue => {
            setNewStartDate(newValue.value);
          }}
        />
        <label htmlFor="newCourseStartDate">{t("date_picker_label")}</label>
      </span>
    </Dialog>
  );

  return (
    <React.Fragment>
      <Button
        tooltip={t("btn_tooltip_title")}
        tooltipOptions={{
          position: "left"
        }}
        icon="pi pi-copy"
        id={"copy-" + props.itemId}
        onClick={event => {
          setCopyData({
            id: props.itemId,
            startDate: props.startDate,
            copyUrl: props.copyUrl
          });
        }}
        aria-label={t("copy_btn_aria")}
        size={t("size_btn")}
      />
      {copyDialog}
    </React.Fragment>
  );
}
