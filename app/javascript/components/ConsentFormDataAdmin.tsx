import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import TextField from "@material-ui/core/TextField";
import InputLabel from "@material-ui/core/InputLabel";
import IconButton from '@material-ui/core/IconButton';
import FormControl from "@material-ui/core/FormControl";
import Select from "@material-ui/core/Select";
import Paper from "@material-ui/core/Paper";
import MenuItem from "@material-ui/core/MenuItem";
import FormHelperText from "@material-ui/core/FormHelperText";
import Collapse from '@material-ui/core/Collapse';
import Alert from '@material-ui/lab/Alert';
import CloseIcon from '@material-ui/icons/Close';

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@date-io/luxon";
import { useEndpointStore } from "./EndPointStore";
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { useUserStore } from "./UserStore";
import { TextareaAutosize } from "@material-ui/core";

export default function ConsentFormDataAdmin(props) {
  const endpointSet = "consent_form";
  const [endpoints, endpointsActions] = useEndpointStore();
  //const { t, i18n } = useTranslation('schools' );
  const [user, userActions] = useUserStore();

  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState( false );

  const [consentFormId, setConsentFormId] = useState(props.consentFormId);
  const [consentFormName, setConsentFormName] = useState("");
  const [consentFormActive, setConsentFormActive] = useState(false);
  const [consentFormStartDate, setConsentFormStartDate] = useState(new Date( ) );
  const [consentFormEndDate, setConsentFormEndDate] = useState(new Date( ) );
  const [consentFormFormTextEn, setConsentFormFormTextEn] = useState("");
  const [consentFormFormTextKo, setConsentFormFormTextKo] = useState("");


  const getConsentForm = () => {
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
        setConsentFormStartDate(consentForm.start_date || '');
        setConsentFormEndDate(consentForm.end_date || '');
        setConsentFormFormTextEn(consentForm.form_text_en || '');
        setConsentFormFormTextKo(consentForm.form_text_ko || '');

        setWorking(false);
        setDirty(false);
      });
  };
  const saveConsentForm = () => {
    const method = null == consentFormId ? "POST" : "PATCH";
    setWorking(true);

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
          start_date: consentFormStartDate,
        }
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          setWorking(false);
        }
      })
      .then(data => {
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const consentForm = data.school;
          setConsentFormId(consentForm.id);
          setConsentFormName(consentForm.name);
          setConsentFormStartDate(consentForm.start_date);
          setConsentFormEndDate(consentForm.end_date);

          setShowErrors( true );
          setDirty(false);
          setMessages(data.messages);
          setWorking(false);
        } else {
          setShowErrors( true );
          setMessages(data.messages);
          setWorking(false);
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
    consentFormEndDate,
  ]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveConsentForm}>
      {null == consentFormId ? "Create" : "Save"} School
    </Button>
  ) : null;

  const detailsComponent = (
    <Paper>
      {working ? <LinearProgress /> : null}
      <TextField
        label="Consent Form Name"
        id="consent_form-name"
        value={consentFormName}
        fullWidth={false}
        onChange={event => setConsentFormName(event.target.value)}
        error={null != messages['name']}
        helperText={messages['name']}
      />
      &nbsp;
      <br/>

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
              id='error-close'
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
