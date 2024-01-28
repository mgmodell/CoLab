import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";

import TextField from "@mui/material/TextField";
import FormControlLabel from "@mui/material/FormControlLabel";
import Switch from "@mui/material/Switch";
import Grid from "@mui/material/Grid";
import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";
import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";

import { Panel } from "primereact/panel";
import { Button } from "primereact/button";

import { DateTime, Settings } from "luxon";
import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import { Editor } from "primereact/editor";
import { TabView, TabPanel } from "primereact/tabview";
import EditorToolbar from "../infrastructure/EditorToolbar";

enum ConsentFormTabs {
  English = 1,
  Korean = 2
}

export default function ConsentFormDataAdmin(props) {
  const category = "consent_form";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { t } = useTranslation(`${category}s`);
  const { consentFormIDParam } = useParams();

  const dispatch = useDispatch();
  const [dirty, setDirty] = useState(false);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const [curTab, setCurTab] = useState(ConsentFormTabs.English);

  const [consentFormId, setConsentFormId] = useState(consentFormIDParam);
  const [consentFormName, setConsentFormName] = useState("");
  const [consentFormActive, setConsentFormActive] = useState(false);
  const [consentFormStartDate, setConsentFormStartDate] = useState(
    DateTime.local()
  );
  const [consentFormEndDate, setConsentFormEndDate] = useState(
    DateTime.local().plus({ year: 1 })
  );
  const [consentFormFormTextEn, setConsentFormFormTextEn] = useState("");
  const [consentFormFormTextKo, setConsentFormFormTextKo] = useState("");
  const [consentFormDoc, setConsentFormDoc] = useState(null);

  const consentFormDataId = "consent_form";

  const handleFileSelect = evt => {
    const file = evt.target.files[0];

    if (file) {
      setConsentFormDoc(file);
    }
  };

  const getConsentForm = () => {
    dispatch(startTask());
    setDirty(true);
    var url = endpoints.baseUrl + "/";
    if (null == consentFormId) {
      url = url + "new.json";
    } else {
      url = url + consentFormId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const consentForm = data.consent_form;

        setConsentFormName(consentForm.name || "");
        setConsentFormActive(consentForm.active || false);
        var receivedDate = DateTime.fromISO(consentForm.start_date).setZone(
          Settings.timezone
        );
        setConsentFormStartDate(receivedDate);
        var receivedDate = DateTime.fromISO(consentForm.end_date).setZone(
          Settings.timezone
        );
        setConsentFormEndDate(receivedDate);
        setConsentFormFormTextEn(consentForm.form_text_en || "");
        setConsentFormFormTextKo(consentForm.form_text_ko || "");

        dispatch(endTask());
        setDirty(false);
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  const saveConsentForm = () => {
    const method = null == consentFormId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null == consentFormId ? null : consentFormId) +
      ".json";

    const formData = new FormData();
    if (consentFormDoc) {
      formData.append;
    }
    axios({
      method: method,
      url: url,
      data: {
        consent_form: {
          name: consentFormName,
          start_date: consentFormStartDate,
          end_date: consentFormEndDate,
          form_text_en: consentFormFormTextEn,
          form_text_ko: consentFormFormTextKo,
          active: consentFormActive
        }
      }
    })
      .then(response => {
        const data = response.data;
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const consentForm = data.consent_form;
          console.log(response);
          setConsentFormId(consentForm.id);
          setConsentFormName(consentForm.name);

          setConsentFormActive(consentForm.active || false);
          var receivedDate = DateTime.fromISO(consentForm.start_date).setZone(
            Settings.timezone
          );
          setConsentFormStartDate(receivedDate);
          var receivedDate = DateTime.fromISO(consentForm.end_date).setZone(
            Settings.timezone
          );
          setConsentFormEndDate(receivedDate);
          setConsentFormFormTextEn(consentForm.form_text_en || "");
          setConsentFormFormTextKo(consentForm.form_text_ko || "");

          setShowErrors(true);
          setDirty(false);
          setMessages(data.messages);
          dispatch(endTask("saving"));
        } else {
          setShowErrors(true);
          setMessages(data.messages);
          dispatch(endTask("saving"));
        }
      })
      .catch(error => {
        console.log("error", error);
        dispatch(endTask("saving"));
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getConsentForm();
    }
  }, [endpointStatus]);

  useEffect(() => setDirty(true), [
    consentFormName,
    consentFormActive,
    consentFormStartDate,
    consentFormEndDate
  ]);

  const saveButton = dirty ? (
    <Button onClick={saveConsentForm}>
      {null == consentFormId ? t("edit.create_btn") : t("edit.save_btn")}
    </Button>
  ) : null;

  const detailsComponent = (
    <Panel>
      <Grid container spacing={3}>
        <LocalizationProvider dateAdapter={AdapterLuxon}>
          <Grid item xs={12}>
            <TextField
              label="Name of the study"
              id="consent_form-name"
              value={consentFormName}
              fullWidth={true}
              onChange={event => setConsentFormName(event.target.value)}
              error={null != messages["name"]}
              helperText={messages["name"]}
            />
          </Grid>
          <Grid item xs={12} sm={5}>
            <DatePicker
              disableToolbar
              variant="inline"
              autoOk={true}
              format="MM/dd/yyyy"
              margin="normal"
              label="Study Start Date"
              value={consentFormStartDate}
              onChange={setConsentFormStartDate}
              error={null != messages["start_date"]}
              helperText={messages["start_date"]}
              slot={{
                TextField: TextField
              }}
              slotProps={{
                textField: {
                  id: "consent_form_start_date"
                }
              }}
            />
          </Grid>
          <Grid item xs={12} sm={5}>
            <DatePicker
              disableToolbar
              variant="inline"
              autoOk={true}
              format="MM/dd/yyyy"
              margin="normal"
              label="Study End Date"
              value={consentFormEndDate}
              onChange={setConsentFormEndDate}
              error={null != messages["end_date"]}
              helperText={messages["end_date"]}
              slot={{
                TextField: TextField
              }}
              slotProps={{
                textField: {
                  id: "consent_form_end_date"
                }
              }}
            />
          </Grid>
          <Grid item xs={12} sm={2}>
            <FormControlLabel
              control={
                <Switch
                  checked={consentFormActive}
                  onChange={event => setConsentFormActive(!consentFormActive)}
                  name="active"
                />
              }
              label="Active"
            />
          </Grid>
        </LocalizationProvider>
      </Grid>
      <TabView>
        <TabPanel header="English">
          <Editor
            id="english_form"
            placeholder={"en_form"}
            aria-label={"en_form"}
            headerTemplate={ <EditorToolbar />}
            onTextChange={event => {
              setConsentFormFormTextEn(event.htmlValue);
            }}
            value={consentFormFormTextEn}
          />
        </TabPanel>
        <TabPanel header="Korean">
          <Editor
            id="korean_form"
            placeholder={"ko_form"}
            aria-label={"ko_form"}
            headerTemplate={ <EditorToolbar />}
            onTextChange={event => {
              setConsentFormFormTextKo(event.htmlValue);
            }}
            value={consentFormFormTextKo}
          />
        </TabPanel>
      </TabView>
      &nbsp;
      <label htmlFor={consentFormDataId}>
        <input
          style={{ display: "none" }}
          id={consentFormDataId}
          name={consentFormDataId}
          onChange={handleFileSelect}
          type="file"
        />
        <Button >
          {t("edit.file_select_btn")}
        </Button>
      </label>
      <br />
      <br />
      {saveButton}
    </Panel>
  );

  return (
    <Panel>
      {detailsComponent}
    </Panel>
  );
}
