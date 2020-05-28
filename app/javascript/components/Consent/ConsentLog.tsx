import React, { useState, useEffect, Suspense } from "react";
import PropTypes from "prop-types";
import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Typography";

import MainMenu from "../MainMenu";
import HelpMenu from "../HelpMenu";
import Quote from "../Quote";
import { i18n } from "../infrastructure/i18n";
import { useTranslation } from "react-i18next";
import Skeleton from "@material-ui/lab/Skeleton";
import { useEndpointStore } from "../infrastructure/EndPointStore";
import Button from "@material-ui/core/Button";
import Grid from "@material-ui/core/Grid";
import Link from "@material-ui/core/Link";
import Paper from '@material-ui/core/Paper'
import { FormControlLabel, Checkbox } from "@material-ui/core";

export default function ConsentLog(props) {
  const { t, i18n } = useTranslation();
  const endpointSet = 'consent_log';
  const [endpoints, endpointsActions] = useEndpointStore();
  const [logId, setLogId] = useState( );
  const [formName, setFormName] = useState( '' );
  const [formText, setFormText] = useState( '' );
  const [formPresented, setFormPresented] = useState( false );
  const [formPdfLink, setFormPdfLink] = useState( '' );
  const [formAccepted, setFormAccepted ] = useState( false );
  const [logLastUpdated, setLogLastUpdated ] = useState( new Date( ) )
  const [working, setWorking] = useState( true );

  const getLog = () => {
    var url = endpoints.endpoints[endpointSet].baseUrl + props.consentFormId + ".json";

    fetch(url, {
      method: "GET",
      credentials: "include",
      cache: "no-cache",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        //Process the data
        setLogId( data.id );
        setFormName( data.name );
        setFormText( data.formText );
        setFormPdfLink( data.pdfLink)
        setFormAccepted( data.accepted );
        setFormPresented( data.presented );
        setLogLastUpdated( new Date( data.updatedAt ) );

        setWorking(false);
      });
  };

  const updateLog = () => {
    var url = endpoints.endpoints[endpointSet].consentLogSaveUrl + logId + ".json";

    fetch(url, {
      method: "PATCH",
      credentials: "include",
      cache: "no-cache",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        consent_log: {
          accepted: formAccepted
        }
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        //Process the data
        setFormAccepted( data.accepted );
        props.parentUpdateFunc( );

        setWorking(false);
      });
  };

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
  }, []);

  useEffect(() =>{
    if( 'loaded' === endpoints.endpointStatus[endpointSet] ){
      getLog( );
    }

  }, [endpoints.endpointStatus[endpointSet]]);

  return (
    <Paper>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Typography variant='h1'>
            {t( 'consent_logs.edit.opening')}
          </Typography>
          <Typography variant='h2'>
            {t( 'consent_logs.edit.title')}: {formName}
          </Typography>

        </Grid>
        <Grid item xs={12}>
          <p>
            {t( 'consent_logs.edit.instructions')}
          </p>
          <p
            dangerouslySetInnerHTML={{
              __html: formText
            }}
          />
        </Grid>
        <Grid item xs={12} sm={6}>
          <Link href={formPdfLink}>
            {t( 'consent_logs.edit.consent_dl')}
          </Link>
        </Grid>
        <Grid item xs={12} sm={6}>
          <FormControlLabel
            control={<Checkbox checked={formAccepted} onChange={(event, value)=>setFormAccepted(!formAccepted)}/>}
            label={t( 'consent_logs.accepted')}
          />
        </Grid>
        <Grid item xs={12} >
          <Button fullWidth onClick={updateLog}>
            {t( 'consent_logs.edit.submit_response')}
          </Button>
        </Grid>
      </Grid>
    </Paper>
  );
}

ConsentLog.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  consentFormId: PropTypes.number.isRequired,
  parentUpdateFunc: PropTypes.func.isRequired
};
