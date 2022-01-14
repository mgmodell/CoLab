import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import PropTypes from "prop-types";
import Typography from "@mui/material/Typography";

import { useTranslation } from "react-i18next";
import {useDispatch} from 'react-redux';
import {startTask, endTask} from '../infrastructure/StatusActions';
import Button from "@mui/material/Button";
import Grid from "@mui/material/Grid";
import Link from "@mui/material/Link";
import Paper from "@mui/material/Paper";
import { FormControlLabel, Checkbox } from "@mui/material";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";

export default function ConsentLog(props) {
  const { t } = useTranslation("consent_logs");
  const endpointSet = "consent_log";
  const endpoints = useTypedSelector(state=>state.context.endpoints[endpointSet])
  const endpointStatus = useTypedSelector(state=>state.context.status.endpointsLoaded );
  const {consentFormId} = useParams( );

  const dispatch = useDispatch( );
  const [logId, setLogId] = useState();
  const [formName, setFormName] = useState("");
  const [formText, setFormText] = useState("");
  const [, setFormPresented] = useState(false);
  const [formPdfLink, setFormPdfLink] = useState("");
  const [formAccepted, setFormAccepted] = useState(false);
  const [logLastUpdated, setLogLastUpdated] = useState(new Date());

  const getLog = () => {
    console.log( props );
    var url =
      endpoints['baseUrl'] + (consentFormId || props.consentFormId ) + ".json";

    console.log( 'get', url );
    dispatch( startTask("loading") );
    axios.get( url, { } )
      .then(response => {
        const data = response.data;
        //Process the data
        console.log('get-resp', response );
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
        consent_log: {
          accepted: formAccepted
        }
    })
      .then(response => {
        const data = response.data;
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
      console.log( 'loading' );
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
  consentFormId: PropTypes.number,
  parentUpdateFunc: PropTypes.func
};
