import React, { Suspense, useState, useEffect } from "react";
import PropTypes from "prop-types";

import Button from "@material-ui/core/Button";
import IconButton from "@material-ui/core/IconButton";
import Paper from "@material-ui/core/Paper";
import Skeleton from "@material-ui/lab/Skeleton";
import ExpansionPanel from "@material-ui/core/ExpansionPanel";
import ExpansionPanelSummary from "@material-ui/core/ExpansionPanelSummary";
import ExpansionPanelDetails from "@material-ui/core/ExpansionPanelDetails";
import ExpandMoreIcon from "@material-ui/icons/ExpandMore";
import TextField from "@material-ui/core/TextField";
import Alert from "@material-ui/lab/Alert";
import Collapse from "@material-ui/core/Collapse";
import CloseIcon from "@material-ui/icons/Close";
//For debug purposes

import { useUserStore } from "./infrastructure/UserStore";
import { useLookupStore } from './infrastructure/LookupStore';
import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";

import LinkedSliders from "./LinkedSliders";

export default function Experience(props) {
  const [lookup, lookupActions] = useLookupStore();

  const [t, i18n] = useTranslation("experiences");

  useEffect(() => {
    lookupActions.fetch(['behaviors'], props.lookupUrl, props.token);
  }, []);

  const saveButton = (
    <Button variant="contained" onClick={() => props.acknowledgeFunc()}>
      <Suspense fallback={<Skeleton variant="text" />}>{t('instructions.next')}</Suspense>
    </Button>
  );


  return (
    <Paper>
      <Suspense fallback={<Skeleton variant='text' />} >
        <h3>{t( 'instructions.title' )}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton variant='rect' />} >
            <p
              dangerouslySetInnerHTML={{
                __html: t('inst_p1')
              }}
            />
      </Suspense>
      <Suspense fallback={<Skeleton variant='rect' />} >
            <p
              dangerouslySetInnerHTML={{
                __html: t('inst_p2')
              }}
            />
      </Suspense>
      <Suspense fallback={<Skeleton variant='rect' />} >
            <p
              dangerouslySetInnerHTML={{
                __html: t('inst_p3')
              }}
            />
      </Suspense>
      <Suspense fallback={<Skeleton variant='text' />} >
        <h3>{t( 'instructions.behaviors_lbl' )}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton variant='rect' />} >
        <dl>
          {(lookup.lookups.behaviors || [] ).map((behavior)=>{
            return(
              <React.Fragment key={behavior.id}>
                <dt>{behavior.name}</dt>
                <dd
                  dangerouslySetInnerHTML={{
                    __html: behavior.description
                  }}
                />
              </React.Fragment>
            )
          })}
        </dl>
      </Suspense>
      <Suspense fallback={<Skeleton variant='text' />} >
        <h3>{t( 'scenario_lbl' )}</h3>

      </Suspense>
      <Suspense fallback={<Skeleton variant='rect' />} >
            <p
              dangerouslySetInnerHTML={{
                __html: t('scenario_p1')
              }}
            />
      </Suspense>
      <Suspense fallback={<Skeleton variant='rect' />} >
            <p
              dangerouslySetInnerHTML={{
                __html: t('scenario_p2')
              }}
            />
      </Suspense>
      <Suspense fallback={<Skeleton variant='rect' />} >
            <p
              dangerouslySetInnerHTML={{
                __html: t('scenario_p3')
              }}
            />
      </Suspense>
      {saveButton}
    </Paper>
  );
}

Experience.propTypes = {
  token: PropTypes.string.isRequired,
  acknowledgeFunc: PropTypes.func.isRequired,
  lookupUrl: PropTypes.string.isRequired

};
