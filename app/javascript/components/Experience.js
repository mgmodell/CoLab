import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import { useNavigate } from "react-router-dom";

//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  setClean,
  addMessage,
  Priorities
} from "./infrastructure/StatusSlice";

import Button from "@mui/material/Button";
import Skeleton from "@mui/material/Skeleton";

import { useTranslation } from "react-i18next";

import ExperienceInstructions from './ExperienceInstructions';
import ExperienceDiagnosis from './ExperienceDiagnosis';

const ExperienceReaction = React.lazy(() => import("./ExperienceReaction"));
import { useTypedSelector } from "./infrastructure/AppReducers";
import axios from "axios";

export default function Experience(props) {
  const endpointSet = "experience";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { experienceId } = useParams();

  const dispatch = useDispatch();
  const [t, i18n] = useTranslation("installments");
  const navigate = useNavigate();

  const [reactionId, setReactionId] = useState();
  const [instructed, setInstructed] = useState(false);

  const [weekId, setWeekId] = useState();
  const [weekNum, setWeekNum] = useState(0);
  const [weekText, setWeekText] = useState("");

  useEffect(() => {
    if (endpointsLoaded) {
      getNext();
    }
  }, [endpointsLoaded]);

  const saveButton = (
    <Button variant="contained" onClick={() => saveDiagnosis()}>
      <Suspense fallback={<Skeleton variant="text" />}>{t("submit")}</Suspense>
    </Button>
  );

  //Retrieve the latest data
  const getNext = () => {
    const url = `${endpoints.baseUrl}${experienceId}.json`;
    dispatch(startTask());
    axios(url, {})
      .then(response => {
        const data = response.data;
        setWeekId(data.week_id);
        setWeekNum(data.week_num);
        setWeekText(data.week_text);

        setReactionId(data.reaction_id);
        setInstructed(data.instructed);

        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  //Store what we've got
  const saveDiagnosis = (behaviorId, otherName, comment, resetFunc) => {
    dispatch(startTask("saving"));
    const url = endpoints.diagnosisUrl + ".json";
    axios
      .patch(url, {
        diagnosis: {
          behavior_id: behaviorId,
          reaction_id: reactionId,
          week_id: weekId,
          other_name: otherName,
          comment: comment
        }
      })
      .then(response => {
        const data = response.data;
        //Process Contributions
        setWeekId(data.week_id);
        setWeekNum(data.week_num);
        setWeekText(data.week_text);

        resetFunc();
        dispatch(addMessage(data.messages.main, new Date(), Priorities.INFO));
        dispatch(endTask("saving"));
        dispatch(setClean("diagnosis"));
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  //React
  const saveReaction = (behaviorId, otherName, improvements, resetFunc) => {
    dispatch(startTask("saving"));
    const url = endpoints.reactionUrl + ".json";
    axios
      .patch(url, {
        reaction: {
          id: reactionId,
          behavior_id: behaviorId,
          other_name: otherName,
          improvements: improvements
        }
      })
      .then(response => {
        const data = response.data;
        //Process Experience
        resetFunc();
        dispatch(addMessage(data.messages.main, new Date(), Priorities.INFO));
        dispatch(endTask("saving"));
        dispatch(setClean("reaction"));
        navigate("/");
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  var output = null;

  if (!endpointsLoaded) {
    output = <Skeleton variant="rectangular" />;
  } else if (!instructed) {
    output = <ExperienceInstructions acknowledgeFunc={getNext} />;
  } else if (undefined === weekNum) {
    output = <ExperienceReaction reactionFunc={saveReaction} />;
  } else {
    output = (
      <ExperienceDiagnosis
        diagnoseFunc={saveDiagnosis}
        weekNum={weekNum}
        weekText={weekText}
      />
    );
  }

  return output;
}

Experience.propTypes = {};
