import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import Button from "@mui/material/Button";
import Box from "@mui/material/Box";
import TextField from "@mui/material/TextField";
import IconButton from "@mui/material/IconButton";
import FormControlLabel from "@mui/material/FormControlLabel";
import Switch from "@mui/material/Switch";
import Paper from "@mui/material/Paper";
import Grid from "@mui/material/Grid";
import Collapse from "@mui/material/Collapse";
import Alert from "@mui/material/Alert";
import CloseIcon from "@mui/icons-material/Close";
import Tab from "@mui/material/Tab";

import {DateTime, Settings} from 'luxon';
import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";
import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";
import { TabContext, TabList, TabPanel } from "@mui/lab/";

import { EditorState, ContentState } from "draft-js";
const Editor = React.lazy(() => import("../reactDraftWysiwygEditor"));

import htmlToDraft from "html-to-draftjs";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";

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

  const [curTab, setCurTab] = useState("en");

  const [consentFormId, setConsentFormId] = useState(consentFormIDParam);
  const [consentFormName, setConsentFormName] = useState("");
  const [consentFormActive, setConsentFormActive] = useState(false);
  const [consentFormStartDate, setConsentFormStartDate] = useState(
    DateTime.local()
    );
  const [consentFormEndDate, setConsentFormEndDate] = useState(
    DateTime.local().plus({year: 1})
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
        setConsentFormFormTextEn(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft(consentForm.form_text_en || "").contentBlocks
            )
          )
        );
        setConsentFormFormTextKo(
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft(consentForm.form_text_ko || "").contentBlocks
            )
          )
        );

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
      data:{
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
          console.log( response );
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
          setConsentFormFormTextEn
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft(consentForm.form_text_en || "").contentBlocks
            )
          );
          EditorState.createWithContent(
            ContentState.createFromBlockArray(
              htmlToDraft(consentForm.form_text_ko || "").contentBlocks
            )
          );

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
    <Button variant="contained" onClick={saveConsentForm}>
      {null == consentFormId ? t('edit.create_btn') : t('edit.save_btn')}
    </Button>
  ) : null;

  const detailsComponent = (
    <Paper>
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
      <TabContext value={curTab}>
        <Box>
          <TabList
            value={curTab}
            onChange={(event, name) => setCurTab(name)}
            centered
          >
            <Tab value="en" label="English" />
            <Tab value="ko" label="Korean" />
          </TabList>
        </Box>
        <TabPanel value="en">
          <Editor
            wrapperId="English Form"
            label={"en_form"}
            placeholder={"en_form"}
            onEditorStateChange={setConsentFormFormTextEn}
            toolbarOnFocus
            toolbar={{
              options: [
                "inline",
                "list",
                "link",
                "blockType",
                "fontSize",
                "fontFamily"
              ],
              inline: {
                options: [
                  "bold",
                  "italic",
                  "underline",
                  "strikethrough",
                  "monospace"
                ],
                bold: { className: "bordered-option-classname" },
                italic: { className: "bordered-option-classname" },
                underline: { className: "bordered-option-classname" },
                strikethrough: { className: "bordered-option-classname" },
                code: { className: "bordered-option-classname" }
              },
              blockType: {
                className: "bordered-option-classname"
              },
              fontSize: {
                className: "bordered-option-classname"
              },
              fontFamily: {
                className: "bordered-option-classname"
              }
            }}
            editorState={consentFormFormTextEn}
          />
        </TabPanel>
        <TabPanel value="ko">
          <Editor
            wrapperId="Korean Form"
            label={"ko_form"}
            placeholder={"ko_form"}
            onEditorStateChange={setConsentFormFormTextKo}
            toolbarOnFocus
            toolbar={{
              options: [
                "inline",
                "list",
                "link",
                "blockType",
                "fontSize",
                "fontFamily"
              ],
              inline: {
                options: [
                  "bold",
                  "italic",
                  "underline",
                  "strikethrough",
                  "monospace"
                ],
                bold: { className: "bordered-option-classname" },
                italic: { className: "bordered-option-classname" },
                underline: { className: "bordered-option-classname" },
                strikethrough: { className: "bordered-option-classname" },
                code: { className: "bordered-option-classname" }
              },
              blockType: {
                className: "bordered-option-classname"
              },
              fontSize: {
                className: "bordered-option-classname"
              },
              fontFamily: {
                className: "bordered-option-classname"
              }
            }}
            editorState={consentFormFormTextKo}
          />
        </TabPanel>
      </TabContext>
      &nbsp;
      <label htmlFor={consentFormDataId}>
        <input
          style={{ display: "none" }}
          id={consentFormDataId}
          name={consentFormDataId}
          onChange={handleFileSelect}
          type="file"
        />
        <Button variant="contained" component="span">
          {t("edit.file_select_btn")}
        </Button>
      </label>
      <br />
      <br />
      {saveButton}
    </Paper>
  );

  return (
    <Paper>
      <Collapse in={showErrors}>
        <Alert
          action={
            <IconButton
              id="error-close"
              aria-label="close"
              color="inherit"
              size="small"
              onClick={() => {
                setShowErrors(false);
              }}
            >
              <CloseIcon fontSize="inherit" />
            </IconButton>
          }
        >
          {messages["main"]}
        </Alert>
      </Collapse>
      {detailsComponent}
    </Paper>
  );
}