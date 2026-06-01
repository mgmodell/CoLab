import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router";

import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
} from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import GuardRedirect, { RedirectState } from "../infrastructure/GuardRedirect";
import { DATETIME_SHORT, formatZonedDateTime, parseISO, TemporalSettings } from "../infrastructure/TemporalSettings";


export default function BingoDirector() {
  const category = "bingo_game";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { t, i18n } = useTranslation(`${category}s`);
  const navigate = useNavigate();

  const { bingoGameId } = useParams();

  const dispatch = useDispatch();

  const [redirectState, setRedirectState] = useState(RedirectState.DECIDING);
  const [redirectUrl, setRedirectUrl] = useState<string | undefined>(undefined);
  const [redirectMessage, setRedirectMessage] = useState("");
  const [redirectMessageHeading, setRedirectMessageHeading] = useState("");

  const getDirection = () => {
    dispatch(startTask());
    const url =
        `${endpoints.activityDirectorUrl}${bingoGameId}.json`;

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        switch (data.messages.target) {
          case 'review_in_progress':
            setRedirectMessageHeading(t("terms_review_in_progress_heading"));
            setRedirectMessage(t("terms_review_in_progress_msg", {
              start_date: formatZonedDateTime(
                parseISO(data.messages.metadata.start_date, TemporalSettings.timezone),
                DATETIME_SHORT
              ),
              end_date: formatZonedDateTime(
                parseISO(data.messages.metadata.end_date, TemporalSettings.timezone),
                DATETIME_SHORT
              )
            } 
            ));
            setRedirectUrl('/home'); 
            setRedirectState(RedirectState.REDIRECT);
            break;
          case 'not_available_yet':
            setRedirectMessageHeading(t("not_available_yet_heading"));
            setRedirectMessage(t("not_available_yet_msg", {
              start_date: formatZonedDateTime(
                parseISO(data.messages.metadata.start_date, TemporalSettings.timezone),
                DATETIME_SHORT
              ) 
            }));
            setRedirectUrl('/home');
            setRedirectState(RedirectState.REDIRECT);
            break;
          case 'no_available_bingo':
            setRedirectMessageHeading(t("no_available_bingo_heading"));
            setRedirectMessage(t("no_available_bingo_msg"));
            setRedirectUrl('/home');
            setRedirectState(RedirectState.REDIRECT);
            break;
          case 'candidate_entry':
            navigate(`/home/bingo/enter_candidates/${bingoGameId}`, { replace: true });
            break;
          case 'results_review':
            navigate(`/home/bingo/candidate_results/${bingoGameId}`, { replace: true });
            break;
          case 'admin':
            navigate(
              `/admin/courses/${data.messages.metadata.course_id}/bingo_game/${bingoGameId}`,
              { replace: true }
            );
            break;
          case 'review_candidates':
              navigate(
                `/home/bingo/review_candidates/${bingoGameId}`,
                { replace: true }
              );
              break;
          default:
            setRedirectMessageHeading(t("unknown_status_heading"));
            setRedirectMessage(t("unknown_status_msg"));
            setRedirectUrl('/home');
            setRedirectState(RedirectState.REDIRECT);
        }


      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getDirection();
    }
  }, [endpointStatus]);

  return(
    <GuardRedirect
      redirectState={redirectState}
      redirectUrl={redirectUrl}
      messageHeading={redirectMessageHeading}
      message={redirectMessage}
    >
      <h1>
        {t("determining_status")}
      </h1>

    </GuardRedirect>
  )

}
