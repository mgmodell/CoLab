import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Typography from "@material-ui/core/Typography";

import { useTranslation } from "react-i18next";
import {useDispatch} from 'react-redux';
import {startTask, endTask} from '../infrastructure/StatusActions';
import Button from "@material-ui/core/Button";
import Grid from "@material-ui/core/Grid";
import Link from "@material-ui/core/Link";
import Paper from "@material-ui/core/Paper";
import { FormControlLabel, Checkbox } from "@material-ui/core";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";

export default function ConsentLog(props) {
  const { t } = useTranslation("consent_logs");
  const endpointSet = "consent_log";
  const endpoints = useTypedSelector(state=>state['context'][endpointSet])
  const endpointStatus = useTypedSelector(state=>state['context']['endpointStatus'])
  const dispatch = useDispatch( );
  const [logId, setLogId] = useState();
  const [formName, setFormName] = useState("");
  const [formText, setFormText] = useState("");
  const [, setFormPresented] = useState(false);
  const [formPdfLink, setFormPdfLink] = useState("");
  const [formAccepted, setFormAccepted] = useState(false);
  const [logLastUpdated, setLogLastUpdated] = useState(new Date());

  const getLog = () => {
    var url =
      endpoints['baseUrl'] + props.consentFormId + ".json";

    dispatch( startTask("loading") );
    axios.get( url, { } )
      .then(data => {
        //Process the data
        console.log(data);
        setLogId(data.consent_log.id);
        setFormName(data.consent_log.name);
        setFormText(data.consent_log.formText);
        setFormPdfLink(data.consent_log.pdfLink);
        setFormAccepted(data.consent_log.accepted || false);
        setFormPresented(data.consent_log.presented);
        setLogLastUpdated(new Date(data.consent_log.updatedAt));

        dispatch( endTask("loading") );
      })
      .catch( error =>{
        console.log( 'error', error );
      });
  };

  const updateLog = () => {
    var url =
      endpoints['consentLogSaveUrl'] + logId + ".json";
    dispatch( startTask("saving") );

    console.log("update", url);

    axios.patch( url, {
      body: JSON.stringify({
        consent_log: {
          accepted: formAccepted
        }
      })
    })
      .then(data => {
        //Process the data
        setFormAccepted(data.accepted);
        if (null != props.parentUpdateFunc) {
          props.parentUpdateFunc();
        } else {
          history.back();
        }

        dispatch( endTask("saving") );
      })
      .catch( error =>{
        console.log( 'error', error )
      });
  };

  useEffect(() => {
    if (endpointStatus ){
      getLog();
    }
  }, [endpointStatus]);

  return (
    <Paper>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Typography variant="h1">{t("edit.opening")}</Typography>
          <Typography variant="h2">
            {t("edit.title")}: {formName}
          </Typography>
        </Grid>
        <Grid item xs={12}>
          <p>{t("edit.instructions")}</p>
          <p
            dangerouslySetInnerHTML={{
              __html: formText
            }}
          />
        </Grid>
        <Grid item xs={12} sm={6}>
          <Link href={formPdfLink}>{t("edit.consent_dl")}</Link>
        </Grid>
        <Grid item xs={12} sm={6}>
          <FormControlLabel
            control={
              <Checkbox
                checked={formAccepted}
                onChange={() => setFormAccepted(!formAccepted)}
              />
            }
            id="accepted"
            label={t("edit.accept")}
          />
        </Grid>
        <Grid item xs={12}>
          <Button fullWidth onClick={updateLog}>
            {t("edit.submit_response")}
          </Button>
        </Grid>
      </Grid>
    </Paper>
  );
}

ConsentLog.propTypes = {
  consentFormId: PropTypes.number.isRequired,
  parentUpdateFunc: PropTypes.func
};
