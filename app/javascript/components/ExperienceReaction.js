import React, { Suspense, useState, useEffect } from "react";
import PropTypes from "prop-types";

import Button from "@material-ui/core/Button";
import IconButton from "@material-ui/core/IconButton";
import Paper from "@material-ui/core/Paper";
import Skeleton from "@material-ui/lab/Skeleton";
import FormControl from '@material-ui/core/FormControlLabel';
import MenuItem from '@material-ui/core/MenuItem'
import FormHelperText from '@material-ui/core/FormHelperText';
import InputLabel from '@material-ui/core/InputLabel';
import ExpansionPanel from "@material-ui/core/ExpansionPanel";
import ExpansionPanelSummary from "@material-ui/core/ExpansionPanelSummary";
import ExpansionPanelDetails from "@material-ui/core/ExpansionPanelDetails";
import ExpandMoreIcon from "@material-ui/icons/ExpandMore";
import TextField from "@material-ui/core/TextField";
import Alert from "@material-ui/lab/Alert";
import Collapse from "@material-ui/core/Collapse";
import CloseIcon from "@material-ui/icons/Close";
//For debug purposes

import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";
import { useStatusStore } from './infrastructure/StatusStore';

import LinkedSliders from "./LinkedSliders";
import Select from "@material-ui/core/Select";
import { Grid } from "@material-ui/core";

export default function ExperienceReaction(props) {
  const [t, i18n] = useTranslation("experiences");
  const [behaviorId, setBehaviorId ] = useState( 0 );
  const [otherName, setOtherName] = useState( '' );
  const [improvements, setImprovements] = useState( '' );
  const [showImprovements, setShowImprovements] = useState( false );
  const [status, statusActions] = useStatusStore( );

  const saveButton = 
    ( <Button disabled={!status.dirtyStatus['reaction']} variant="contained" onClick={() => props.reactionFunc( behaviorId, otherName, improvements)}>
      <Suspense fallback={<Skeleton variant="text" />}>{t('submit')}</Suspense>
    </Button>)

  const getById = (list, id) =>{
    return list.filter( (item) =>{
      return id === item.id;
    })[0];
  }
  const otherPnl = (0 !== behaviorId && getById( props.behaviors, behaviorId ).needs_detail ) ? (
    <TextField
      variant='filled'
      label={t( 'next.other' )}
      value={otherName}
      onChange={(event)=>{setOtherName(event.target.value)}}
    />

   ) : null;

  return (
    <Paper>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton variant='text' />} >
            <h3>{t( 'reaction.title' )}</h3>
          </Suspense>
        </Grid>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton variant='rect' />} >
                <p
                  dangerouslySetInnerHTML={{
                    __html: t( 'reaction.instructions')
                  }}
                />
          </Suspense>

        </Grid>
        <Grid item xs={12} sm={6}>
          <InputLabel htmlFor="course_school" id="course_school_lbl">
            <h3>{t( 'reaction.dom_behavior' )}</h3>
          </InputLabel>
          <Select
            id="behavior"
            value={behaviorId}
            onChange={event => {
              statusActions.setDirty( 'reaction' )
              setBehaviorId(Number(event.target.value));
            }}
          >
            <MenuItem value={0}>None Selected</MenuItem>
            {props.behaviors.map(behavior => {
              return (
                <MenuItem key={"behavior_" + behavior.id} value={behavior.id}>
                  {behavior.name}
                </MenuItem>
              );
            })}
          </Select>

        </Grid>
        <Grid item xs={12} sm={6}>
          {otherPnl }
        </Grid>
        <Grid item xs={12}>
          <ExpansionPanel expanded={showComments} onChange={()=>setShowComments( !showComments)} >
            <ExpansionPanelSummary id='comments_pnl'>
              {t( 'reaction.improve')}
            </ExpansionPanelSummary>
            <ExpansionPanelDetails>
              <TextField
                variant='filled'
                label={t( 'reaction.improve' )}
                value={improvements}
                onChange={(event)=>{setImprovements(event.target.value)}}
              />

            </ExpansionPanelDetails>
          </ExpansionPanel>
          
        </Grid>
      </Grid>
      {saveButton}
    </Paper>
  );
}

ExperienceReaction.propTypes = {
  reactionFunc: PropTypes.func.isRequired,
  behaviors: PropTypes.array.isRequired,
};
