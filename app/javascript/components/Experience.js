import React, { Suspense, useState, useEffect } from "react";
import { useHistory } from "react-router-dom";
import PropTypes from "prop-types";

//Redux store stuff
import { useDispatch } from 'react-redux';
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  acknowledgeMsg} from './infrastructure/StatusActions';

import Button from "@material-ui/core/Button";
import Skeleton from "@material-ui/lab/Skeleton";

import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";

import ExperienceInstructions from "./ExperienceInstructions";
import ExperienceDiagnosis from "./ExperienceDiagnosis";
import ExperienceReaction from "./ExperienceReaction";
import { useTypedSelector } from "./infrastructure/AppReducers";
import axios from "axios";

export default function Experience(props) {
  const endpointSet = "experience";
  const endpoints = useTypedSelector(state=>state.context.endpoints[endpointSet])
  const endpointStatus = useTypedSelector(state=>state.context.endpointsLoaded );
  const dispatch = useDispatch( );
  const [t, i18n] = useTranslation("installments");
  const history = useHistory();

  const [reactionId, setReactionId] = useState();
  const [instructed, setInstructed] = useState(false);

  const [weekId, setWeekId] = useState();
  const [weekNum, setWeekNum] = useState(0);
  const [weekText, setWeekText] = useState("");

  useEffect(() => {
    if (endpointStatus ){
      getNext();
    }
  }, [endpointStatus]);

  const saveButton = (
    <Button variant="contained" onClick={() => saveDiagnosis()}>
      <Suspense fallback={<Skeleton variant="text" />}>{t("submit")}</Suspense>
    </Button>
  );

  //Retrieve the latest data
  const getNext = () => {
    const url = `${endpoints.baseUrl}${
      props.experienceId
    }.json`;
    dispatch( startTask() );
    axios( url, { } )
      .then(data => {
        setWeekId(data.week_id);
        setWeekNum(data.week_num);
        setWeekText(data.week_text);

        setReactionId(data.reaction_id);
        setInstructed(data.instructed);

        dispatch( endTask() );
      })
      .catch( error =>{
        console.log( 'error', error );
      });
  };
  //Store what we've got
  const saveDiagnosis = (behaviorId, otherName, comment, resetFunc) => {
    dispatch( startTask( 'saving' ) );
    const url = endpoints.diagnosisUrl;
    axios.patch( url, {
      body: JSON.stringify({
        diagnosis: {
          behavior_id: behaviorId,
          reaction_id: reactionId,
          week_id: weekId,
          other_name: otherName,
          comment: comment
        }
      })

    })
      .then(data => {
        //Process Contributions
        setWeekId(data.week_id);
        setWeekNum(data.week_num);
        setWeekText(data.week_text);

        resetFunc();
        dispatch( addMessage( data.messages.main, Date.now( ), 1 ) )
        dispatch( endTask( 'saving' ) );
        dispatch( setClean('diagnosis') );
      })
      .catch( error =>{
        console.log( 'error', error );
      });
  };

  //React
  const saveReaction = (behaviorId, otherName, improvements, resetFunc) => {
    dispatch( startTask( 'saving' ) );
    const url = endpoints.reactionUrl;
    axios.patch( url, { 
      body: JSON.stringify({
        reaction: {
          id: reactionId,
          behavior_id: behaviorId,
          other_name: otherName,
          improvements: improvements
        }
      })
    })
      .then(data => {
        //Process Experience
        resetFunc();
        dispatch( addMessage( data.messages.main, Date.now( ), 1 ) )
        dispatch( endTask( 'saving' ) );
        dispatch( setClean( 'reaction' ) );
        history.push("/");
      })
      .catch( error =>{
        console.log( 'error', error );
      });
  };

  var output = null;
  if (endpointStatus) {
    output = <Skeleton variant="rect" />;
  } else if (!instructed) {
    output = (
      <ExperienceInstructions
        lookupUrl={endpoints.lookupsUrl}
        acknowledgeFunc={getNext}
      />
    );
  } else if (undefined === weekNum) {
    output = (
      <ExperienceReaction
        lookupUrl={endpoints.lookupsUrl}
        reactionFunc={saveReaction}
      />
    );
  } else {
    output = (
      <ExperienceDiagnosis
        lookupUrl={endpoints.lookupsUrl}
        diagnoseFunc={saveDiagnosis}
        weekNum={weekNum}
        weekText={weekText}
      />
    );
  }

  return output;
}

Experience.propTypes = {
  experienceId: PropTypes.number.isRequired
};
