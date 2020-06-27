import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import TextField from "@material-ui/core/TextField";
import InputLabel from "@material-ui/core/InputLabel";
import IconButton from "@material-ui/core/IconButton";
import FormControl from "@material-ui/core/FormControl";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Switch from "@material-ui/core/Switch";
import Select from "@material-ui/core/Select";
import Paper from "@material-ui/core/Paper";
import MenuItem from "@material-ui/core/MenuItem";
import FormHelperText from "@material-ui/core/FormHelperText";
import Grid from "@material-ui/core/Grid";
import Collapse from "@material-ui/core/Collapse";
import Alert from "@material-ui/lab/Alert";
import CloseIcon from "@material-ui/icons/Close";

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import { useEndpointStore } from "../infrastructure/EndPointStore";
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { useUserStore } from "../infrastructure/UserStore";
import { useStatusStore } from "../infrastructure/StatusStore";
import { DatePicker, LocalizationProvider } from "@material-ui/pickers";
import Tabs from "@material-ui/core/Tabs";
import Tab from "@material-ui/core/Tab";

import { EditorState, convertToRaw, ContentState } from "draft-js";
import { Editor } from "react-draft-wysiwyg";
import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";

export default function ConsentFormDataAdmin(props) {
  const endpointSet = "consent_form";
  const [endpoints, endpointsActions] = useEndpointStore();
  //const { t, i18n } = useTranslation('schools' );
  const [user, userActions] = useUserStore();
  const [status, statusActions] = useStatusStore();

  const [dirty, setDirty] = useState(false);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const [curTab, setCurTab] = useState("en");

  const [consentFormId, setConsentFormId] = useState(props.consentFormId);
  const [consentFormName, setConsentFormName] = useState("");
  const [consentFormActive, setConsentFormActive] = useState(false);
  const [consentFormStartDate, setConsentFormStartDate] = useState(new Date());
  const [consentFormEndDate, setConsentFormEndDate] = useState(new Date());
  const [consentFormFormTextEn, setConsentFormFormTextEn] = useState("");
  const [consentFormFormTextKo, setConsentFormFormTextKo] = useState("");

  const getConsentForm = () => {
    statusActions.startTask();
    setDirty(true);
    var url = endpoints.endpoints[endpointSet].baseUrl + "/";
    if (null == consentFormId) {
      url = url + "new.json";
    } else {
      url = url + consentFormId + ".json";
    }
    fetch(url, {
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
          return response.json();
        }
      })
      .then(data => {
        const consentForm = data.consent_form;

        setConsentFormName(consentForm.name || "");
        setConsentFormActive(consentForm.active || false);
        var receivedDate = new Date(consentForm.start_date);
        setConsentFormStartDate(receivedDate);
        receivedDate = new Date(consentForm.end_date);
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

        statusActions.endTask();
        setDirty(false);
      });
  };
  const saveConsentForm = () => {
    const method = null == consentFormId ? "POST" : "PATCH";
    statusActions.startTask("saving");

    const url =
      endpoints.endpoints[endpointSet].baseUrl +
      "/" +
      (null == consentFormId ? props.schoolId : consentFormId) +
      ".json";

    fetch(url, {
      method: method,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        consent_form: {
          id: consentFormId,
          name: consentFormName,
          start_date: consentFormStartDate
        }
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          statusActions.endTask("saving");
        }
      })
      .then(data => {
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const consentForm = data.school;
          setConsentFormId(consentForm.id);
          setConsentFormName(consentForm.name);

          setConsentFormActive(consentForm.active || false);
          var receivedDate = new Date(consentForm.start_date);
          setConsentFormStartDate(receivedDate);
          receivedDate = new Date(consentForm.end_date);
          setConsentFormEndDate(receivedDate);
          setConsentFormFormTextEn(consentForm.form_text_en || "");
          setConsentFormFormTextKo(consentForm.form_text_ko || "");

          setShowErrors(true);
          setDirty(false);
          setMessages(data.messages);
          statusActions.endTask("saving");
        } else {
          setShowErrors(true);
          setMessages(data.messages);
          statusActions.endTask("saving");
        }
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      getConsentForm();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  useEffect(() => setDirty(true), [
    consentFormName,
    consentFormActive,
    consentFormStartDate,
    consentFormEndDate
  ]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveConsentForm}>
      {null == consentFormId ? "Create" : "Save"} School
    </Button>
  ) : null;

  const detailsComponent = (
    <Paper>
      <Grid container spacing={3}>
        <LocalizationProvider dateAdapter={LuxonUtils}>
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
              inputFormat="MM/dd/yyyy"
              margin="normal"
              label="Study Start Date"
              value={consentFormStartDate}
              onChange={setConsentFormStartDate}
              error={null != messages["start_date"]}
              helperText={messages["start_date"]}
              renderInput={props => (
                <TextField id="consent_form_start_date" {...props} />
              )}
            />
          </Grid>
          <Grid item xs={12} sm={5}>
            <DatePicker
              disableToolbar
              variant="inline"
              autoOk={true}
              inputFormat="MM/dd/yyyy"
              margin="normal"
              label="Study End Date"
              value={consentFormEndDate}
              onChange={setConsentFormEndDate}
              error={null != messages["end_date"]}
              helperText={messages["end_date"]}
              renderInput={props => (
                <TextField id="consent_form_end_date" {...props} />
              )}
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
      <Tabs value={curTab} onChange={(event, name) => setCurTab(name)} centered>
        <Tab value="en" label="English" />
        <Tab value="ko" label="Korean" />
      </Tabs>
      {"en" === curTab ? (
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
      ) : null}
      {"ko" === curTab ? (
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
      ) : null}
      &nbsp;
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

ConsentFormDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  consentFormId: PropTypes.number
};
