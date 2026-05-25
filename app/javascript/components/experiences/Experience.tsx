import React, { Suspense, useState, useEffect } from "react";
import { useParams } from "react-router";
import { useNavigate } from "react-router";

//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  setClean,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";

import { useTranslation } from "react-i18next";

import ExperienceInstructions from "./ExperienceInstructions";
import ExperienceDiagnosis from "./ExperienceDiagnosis";

import ExperienceReaction from "./ExperienceReaction";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTour } from "../infrastructure/TourContext";
import axios from "axios";
import { Skeleton } from "primereact/skeleton";
import GuardRedirect, { RedirectState } from "../infrastructure/GuardRedirect";
import { DATETIME_SHORT, formatZonedDateTime, parseISO, TemporalSettings } from "../infrastructure/TemporalSettings";

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
  const [t] = useTranslation("experiences");
  const navigate = useNavigate();
  const { setTourSteps } = useTour();
  const [redirectState, setRedirectState] = useState( RedirectState.DECIDING );
  const [redirectUrl, setRedirectUrl] = useState<string | undefined>(undefined);
  const [redirectMessage, setRedirectMessage] = useState("");
  const [redirectMessageHeading, setRedirectMessageHeading] = useState("");

  useEffect(() => {
    setTourSteps([
      {
        element: ".journal_entry",
        popover: {
          description: t("inst_p1"),
          align: "center",
          side: "left"
        }
      },
      {
        element: ".behaviors",
        popover: {
          description: t("inst_p2"),
          align: "center",
          side: "right"
        }
      },
      {
        element: "body",
        popover: {
          description: t("inst_p3"),
          align: "center",
          side: "top"
        }
      }
    ]);
    return () => setTourSteps([]);
  }, [setTourSteps, t]);

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

  //Retrieve the latest data
  const getNext = () => {
    const url = `${endpoints.baseUrl}${experienceId}.json`;
    dispatch(startTask());
    axios(url, {})
      .then(response => {
        const data = response.data;
        if( data.messages?.error ){
          if( 'experience_instructor_redirect' === data.messages.error_type ){
            navigate(`/admin/courses/${data.messages.error_data.course_id}/experience/${data.messages.error_data.experience_id}`);
          } else if( 'no_available_experience' === data.messages.error_type ){
            setRedirectMessage( t("no_available_experience_msg") );
            setRedirectMessageHeading( t("no_available_experience_hdng") );
            setRedirectUrl("/home");
            setRedirectState( RedirectState.REDIRECT );
          } else {
            setRedirectMessageHeading( t("experience_not_open_hdng")  );
            setRedirectMessage( t("experience_not_open_msg", { 
              start_date: formatZonedDateTime(
                parseISO( data.messages.error_data.start_date, TemporalSettings.timezone ),
                DATETIME_SHORT
              ),
              end_date:
                formatZonedDateTime(
                  parseISO( data.messages.error_data.end_date, TemporalSettings.timezone ),
                  DATETIME_SHORT
              ) }) );
            setRedirectUrl("/home");
            setRedirectState( RedirectState.REDIRECT );
          }
        } else {
          const data = response.data;
          setWeekId(data.week_id);
          setWeekNum(data.week_num);
          setWeekText(data.week_text);

          setReactionId(data.reaction_id);
          setInstructed(data.instructed);
          setRedirectState( RedirectState.STAY );
        }

      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
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
        navigate("/home");
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  var output = null;

  if (!endpointsLoaded) {
    output = <Skeleton className="mb-2" />;
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

  return(
    <GuardRedirect
      redirectState={redirectState}
      redirectUrl={redirectUrl}
      message={redirectMessage}
      messageHeading={redirectMessageHeading}
      secondsUntilRedirect={4.5}
    >
      {output}
    </GuardRedirect>
  )
}
