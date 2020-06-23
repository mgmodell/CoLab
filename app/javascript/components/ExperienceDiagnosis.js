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

import Radio from '@material-ui/core/Radio';
import Grid from '@material-ui/core/Grid';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormLabel from "@material-ui/core/FormLabel";

export default function ExperienceDiagnosis(props) {
  const [t, i18n] = useTranslation("experiences");
  const [behaviorId, setBehaviorId ] = useState( 0 );
  const [otherName, setOtherName] = useState( '' );
  const [comments, setComments] = useState( '' );
  const [showComments, setShowComments] = useState( false );
  const [status, statusActions] = useStatusStore( );

  const getById = (list, id) =>{
    return list.filter( (item) =>{
      return id === item.id;
    })[0];
  }

  const detailNeeded = 0 === behaviorId ? false : getById( props.behaviors, behaviorId ).needs_detail;
  const detailPresent = otherName.length > 0;
  const saveButton = 
    ( <Button
        disabled={( !status.dirtyStatus['diagnosis'] ) && (!detailNeeded || detailPresent)}
        variant="contained"
        onClick={() => props.diagnoseFunc( behaviorId, otherName, comments, resetData )}>
      <Suspense fallback={<Skeleton variant="text" />}>{t('next.save_and_continue')}</Suspense>
    </Button>)

  const otherPnl = (0 !== behaviorId && detailNeeded ) ? (
    <TextField
      variant='filled'
      label={t( 'next.other' )}
      id="other_name"
      value={otherName}
      onChange={(event)=>{setOtherName(event.target.value)}}
    />

   ) : null;

  const resetData = ()=>{
    setBehaviorId( 0 );
    setOtherName( '' );
    setComments( '' );
    setShowComments( false );
  }

  return (
    <Paper>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton variant='text' />} >
            <h3>{t( 'next.journal', {week_num: props.weekNum } )}</h3>
          </Suspense>
        </Grid>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton variant='rect' />} >
                <p
                  dangerouslySetInnerHTML={{
                    __html: props.weekText
                  }}
                />
          </Suspense>

        </Grid>
        <Grid item xs={12} sm={6}>

          <FormLabel>
            {t( 'next.prompt' ) }
          </FormLabel>
            <RadioGroup
              aria-label='behavior'
              value={behaviorId}
              onChange={(event)=>{
                statusActions.setDirty( 'diagnosis' );
                setBehaviorId(Number(event.target.value) );
              }}
              >
            {props.behaviors.map(behavior => {
              return (
                <React.Fragment
                    key={"behavior_" + behavior.id}
                >
                  <FormControlLabel
                    value={behavior.id}
                    label={behavior.name}
                    control={<Radio />}
                    />
                  <p
                    dangerouslySetInnerHTML={{
                      __html: behavior.description
                    }}
                    />

                </React.Fragment>
              );
            })}
            </RadioGroup>

        </Grid>
        <Grid item xs={12} sm={6}>
          {otherPnl }
        </Grid>
        <Grid item xs={12}>
          <ExpansionPanel expanded={showComments} onChange={()=>setShowComments( !showComments)} >
            <ExpansionPanelSummary id='comments_pnl'>
              {t( 'next.click_for_comment')}
            </ExpansionPanelSummary>
            <ExpansionPanelDetails>
              <TextField
                variant='filled'
                label={t( 'next.comments' )}
                value={comments}
                id='comments'
                onChange={(event)=>{setComments(event.target.value)}}
              />

            </ExpansionPanelDetails>
          </ExpansionPanel>
          
        </Grid>
      </Grid>
      {saveButton}
    </Paper>
  );
}

ExperienceDiagnosis.propTypes = {
  diagnoseFunc: PropTypes.func.isRequired,
  behaviors: PropTypes.array.isRequired,
  weekNum: PropTypes.number.isRequired,
  weekText: PropTypes.string.isRequired

};
