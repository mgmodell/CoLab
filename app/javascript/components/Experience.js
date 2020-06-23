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
import { useEndpointStore } from"./infrastructure/EndPointStore";
import { useStatusStore } from './infrastructure/StatusStore';
import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";

import ExperienceInstructions from "./ExperienceInstructions";
import ExperienceDiagnosis from "./ExperienceDiagnosis";
import ExperienceReaction from "./ExperienceReaction";

export default function Experience(props) {
  const endpointSet = "experience";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [status, statusActions] = useStatusStore( );
  const [t, i18n] = useTranslation("installments");

  const [reactionId, setReactionId] = useState( );
  const [instructed, setInstructed] = useState( false );
  const [behaviors, setBehaviors] = useState( [] );

  const [weekId, setWeekId] = useState( );
  const [weekNum, setWeekNum] = useState( 0 );
  const [weekText, setWeekText] = useState( '' );

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] === "loaded") {
      getNext();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  const saveButton = (
    <Button variant="contained" onClick={() => saveDiagnosis()}>
      <Suspense fallback={<Skeleton variant="text" />}>{t("submit")}</Suspense>
    </Button>
  );

  //Retrieve the latest data
  const getNext = () => {
    const url = `${endpoints.endpoints[endpointSet].baseUrl}${props.experienceId}.json`;
    console.log( 'get next')
    statusActions.startTask();
    fetch(url, {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          //setMessages({});
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        console.log( data );
        setWeekId( data.week_id );
        setWeekNum( data.week_num );
        setWeekText( data.week_text );

        setBehaviors( data.behaviors );
        setReactionId( data.reaction_id );
        setInstructed( data.instructed );

        statusActions.endTask( );
      });
  };
  //Store what we've got
  const saveDiagnosis = (behaviorId, otherName, comment, resetFunc ) => {
    statusActions.startTask( 'saving' );
    console.log( 'diagnosing' );
    const url =
    endpoints.endpoints[endpointSet].diagnosisUrl
    fetch(url, {
      method: 'PATCH',
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
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
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        //Process Contributions
        console.log( data );
        setWeekId( data.week_id );
        setWeekNum( data.week_num );
        setWeekText( data.week_text );
        console.log( 'diagnosed' );

        resetFunc( );
        statusActions.endTask( 'saving' );
        statusActions.setClean( 'diagnosis' );
      });
  };

  //React
  const saveReaction = (behaviorId, otherName, improvements, resetFunc ) => {
    statusActions.startTask( 'saving' );
    console.log( 'reacting')
    const url =
    endpoints.endpoints[endpointSet].reactionUrl
    console.log( url );
    fetch(url, {
      method: 'PATCH',
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        reaction: {
          id: reactionId,
          behavior_id: behaviorId,
          other_name: otherName,
          improvements: improvements
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
        //Process Contributions

        resetFunc( );
        console.log( 'reacted')
        statusActions.endTask( 'saving' );
        statusActions.setClean( 'reaction' );
      });
  };

  var output = null;
  if( behaviors.length < 1 ){
    output = (<Skeleton variant='rect' />)

  } else if( !instructed ){
    output = (<ExperienceInstructions behaviors={behaviors} acknowledgeFunc={getNext} />)
  } else if( undefined === weekNum ){
    output = (<ExperienceReaction
      behaviors={behaviors}
      reactionFunc={saveReaction}
      />)
  } else {
    output = (<ExperienceDiagnosis
      behaviors={behaviors}
      diagnoseFunc={saveDiagnosis}
      weekNum={weekNum}
      weekText={weekText}
      />)
  }

  return output;
}

Experience.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  experienceId: PropTypes.number.isRequired
};
