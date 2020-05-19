import React, { useState, useEffect, Suspense } from "react";
import PropTypes from "prop-types";
import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Typography";

import MainMenu from "./MainMenu";
import HelpMenu from "./HelpMenu";
import Quote from "./Quote";
import { i18n } from "./i18n";
import { useTranslation } from "react-i18next";
import Skeleton from "@material-ui/lab/Skeleton";
import { useEndpointStore } from "./EndPointStore";
import Button from "@material-ui/core/Button";
import Grid from "@material-ui/core/Grid";
import Link from "@material-ui/core/Link";
import Paper from '@material-ui/core/Paper'
import { FormControlLabel, Checkbox } from "@material-ui/core";

export default function ConsentLog(props) {
  const { t, i18n } = useTranslation();
  //const [endpoints, setEndpoints] = useState({})
  const endpointSet = "consent_log";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [formName, setFormName] = useState( '' );
  const [formText, setFormText] = useState( '' );
  const [formPdfLink, setFormPdfLink] = useState( '' );
  const [formAccepted, setFormAccepted ] = useState( false );

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
  }, []);

  return (
    <Paper>
      <Typography variant='h1'>
        {t( 'consent_logs.edit.opening')}
      </Typography>
      <Typography variant='h2'>
        {t( 'consent_logs.edit.title')}
      </Typography>
      <Grid container spacing={3}>
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
        <Grid xs={12} sm={6}>
          <Link href={formPdfLink}>
            {t( 'consent_logs.edit.consent_dl')}
          </Link>
        </Grid>
        <Grid xs={12} sm={6}>
          <FormControlLabel
            control={<Checkbox checked={formAccepted} onChange={(event, value)=>setFormAccepted(!formAccepted)}/>}
            label={t( 'consent_logs.accepted')}
          />
        </Grid>
        <Grid xs={12} >
          <Button fullWidth onClick={()=>console.log( 'I hate you')}>
            {t( 'consent_logs.edit.submit_response')}
          </Button>


        </Grid>

      </Grid>


    </Paper>
  );
}

ConsentLog.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
