import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Typography from "@material-ui/core/Typography";

import { useTranslation } from "react-i18next";
import { useEndpointStore } from "../infrastructure/EndPointStore";
import { useStatusStore } from '../infrastructure/StatusStore';
import Button from "@material-ui/core/Button";
import Grid from "@material-ui/core/Grid";
import Link from "@material-ui/core/Link";
import Paper from '@material-ui/core/Paper'
import { FormControlLabel, Checkbox } from "@material-ui/core";

export default function ConsentLog(props) {
  const { t } = useTranslation( 'consent_logs');
  const endpointSet = 'consent_log';
  const [endpoints, endpointsActions] = useEndpointStore();
  const [status, statusActions] = useStatusStore( );
  const [logId, setLogId] = useState( );
  const [formName, setFormName] = useState( '' );
  const [formText, setFormText] = useState( '' );
  const [, setFormPresented] = useState( false );
  const [formPdfLink, setFormPdfLink] = useState( '' );
  const [formAccepted, setFormAccepted ] = useState( false );
  const [logLastUpdated, setLogLastUpdated ] = useState( new Date( ) )

  const getLog = () => {
    var url = endpoints.endpoints[endpointSet].baseUrl + props.consentFormId + ".json";

    statusActions.startTask( 'loading')
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
        console.log( data );
        setLogId( data.consent_log.id );
        setFormName( data.consent_log.name );
        setFormText( data.consent_log.formText );
        setFormPdfLink( data.consent_log.pdfLink)
        setFormAccepted( data.consent_log.accepted || false );
        setFormPresented( data.consent_log.presented );
        setLogLastUpdated( new Date( data.consent_log.updatedAt ) );

        statusActions.endTask( 'loading')
      });
  };

  const updateLog = () => {
    var url = endpoints.endpoints[endpointSet].consentLogSaveUrl + logId + ".json";
    statusActions.startTask( 'saving' );

    console.log( 'update', url );

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
        if( null != props.parentUpdateFunc ){
          props.parentUpdateFunc( );
        } else {
          history.back( );
        }

        statusActions.endTask( 'saving' );
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
            {t( 'edit.opening')}
          </Typography>
          <Typography variant='h2'>
            {t( 'edit.title')}: {formName}
          </Typography>

        </Grid>
        <Grid item xs={12}>
          <p>
            {t( 'edit.instructions')}
          </p>
          <p
            dangerouslySetInnerHTML={{
              __html: formText
            }}
          />
        </Grid>
        <Grid item xs={12} sm={6}>
          <Link href={formPdfLink}>
            {t( 'edit.consent_dl')}
          </Link>
        </Grid>
        <Grid item xs={12} sm={6}>
          <FormControlLabel
            control={<Checkbox checked={formAccepted} onChange={()=>setFormAccepted(!formAccepted)}/>}
            id='accepted'
            label={t( 'edit.accept')}
          />
        </Grid>
        <Grid item xs={12} >
          <Button fullWidth onClick={updateLog}>
            {t( 'edit.submit_response')}
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
  parentUpdateFunc: PropTypes.func
};
