import React, { Suspense, useState, useEffect } from "react";
import PropTypes from "prop-types";
import { useSelector, useDispatch } from 'react-redux';
import {
  startTask,
  endTask,
  addMessage,
  setDirty,
  setClean
} from './infrastructure/StatusActions';


import Button from "@material-ui/core/Button";
import Paper from "@material-ui/core/Paper";
import Skeleton from "@material-ui/lab/Skeleton";
import TextField from "@material-ui/core/TextField";

import { useTranslation } from "react-i18next";
import { i18n } from "./infrastructure/i18n";
import {useTypedLookup, useTypedSelector} from './infrastructure/AppReducers';

import Radio from "@material-ui/core/Radio";
import Grid from "@material-ui/core/Grid";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import RadioGroup from "@material-ui/core/RadioGroup";
import FormLabel from "@material-ui/core/FormLabel";
export default function ExperienceReaction(props) {
  const [t, i18n] = useTranslation("experiences");
  const [behaviorId, setBehaviorId] = useState(0);
  const [otherName, setOtherName] = useState("");
  const [improvements, setImprovements] = useState("");
  const dirtyStatus = useSelector( state =>{ return state.status.dirtyStatus['reaction'] });
  const dispatch = useDispatch( );
  const behaviors = useTypedSelector(state=>state.context.lookups.behaviors);

  const getById = (list, id) => {
    return list.filter(item => {
      return id === item.id;
    })[0];
  };

  const detailNeeded =
    0 === behaviorId
      ? true
      : getById(behaviors, behaviorId).needs_detail;
  const detailPresent = otherName.length > 0;
  const improvementsPresent = improvements.length > 0;
  const saveButton = (
    <Button
      disabled={
        !dirtyStatus || !improvementsPresent || (detailNeeded && !detailPresent)
      }
      variant="contained"
      onClick={() =>
        props.reactionFunc(behaviorId, otherName, improvements, resetData)
      }
    >
      <Suspense fallback={<Skeleton variant="text" />}>
        {t("reaction.submit")}
      </Suspense>
    </Button>
  );
  const otherPnl =
    0 !== behaviorId &&
    getById(behaviors, behaviorId).needs_detail ? (
      <TextField
        variant="filled"
        label={t("next.other")}
        value={otherName}
        onChange={event => {
          setOtherName(event.target.value);
        }}
      />
    ) : null;

  const resetData = () => {
    setBehaviorId(0);
    setOtherName("");
    setImprovements("");
  };

  return (
    <Paper>
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton variant="text" />}>
            <h3>{t("reaction.title")}</h3>
          </Suspense>
        </Grid>
        <Grid item xs={12}>
          <Suspense fallback={<Skeleton variant="rect" />}>
            <p
              dangerouslySetInnerHTML={{
                __html: t("reaction.instructions")
              }}
            />
          </Suspense>
        </Grid>
        <Grid item xs={12} >
          <FormLabel>{t("reaction.dom_behavior")}</FormLabel>
          {behaviors !== undefined ? (
            <RadioGroup
              aria-label="behavior"
              value={behaviorId}
              onChange={event => {
                dispatch( setDirty( 'reaction' ) );
                setBehaviorId(Number(event.target.value));
              }}
            >
              {behaviors.map(behavior => {
                return (
                  <React.Fragment key={"behavior_" + behavior.id}>
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
          ) : (
            <Skeleton variant="rect" />
          )}
        </Grid>
        <Grid item xs={12} >
          {otherPnl}
        </Grid>
        <Grid item xs={12}>
          <h3>{t("reaction.improve")}</h3>
          <TextField
            variant="filled"
            label={t("reaction.suggest")}
            value={improvements}
            id="improvements"
            onChange={event => {
              setImprovements(event.target.value);
            }}
          />
        </Grid>
      </Grid>
      {saveButton}
    </Paper>
  );
}

ExperienceReaction.propTypes = {
  reactionFunc: PropTypes.func.isRequired
};
