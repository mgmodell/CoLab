import React, { useEffect } from "react";
import { useNavigate } from "react-router";

import { Skeleton } from "primereact/skeleton";
import { useDispatch } from "react-redux";
import { endTask, startTask } from "./StatusSlice";
import WorkingIndicator from "./WorkingIndicator";

import { useTranslation } from "react-i18next";

import { Panel } from "primereact/panel";

enum RedirectState {
  REDIRECT,
  STAY,
  DECIDING
}

interface Props {
  redirectUrl?: string;
  messageHeading: string;
  message: string;
  redirectState: RedirectState;
  secondsUntilRedirect?: number;
  children: React.ReactNode;
}

const SECONDS = 1000;
export default function GuardRedirect(props: Props) {
  const [t] = useTranslation('');
  const navigate = useNavigate();
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(startTask());
  }, []);

  useEffect(() => {
    if( RedirectState.REDIRECT === props.redirectState && props.redirectUrl !== undefined ) {
      const timer = setTimeout(() => {
        dispatch(endTask());
        navigate(props.redirectUrl || '/home');
      }, (props.secondsUntilRedirect || 5) * SECONDS);
      return () => clearTimeout(timer);
    } else if ( RedirectState.STAY === props.redirectState ) {
      dispatch(endTask());
    }
  }, [props.redirectUrl, props.redirectState, navigate]);


  return (
    <Panel>
      {RedirectState.DECIDING === props.redirectState ? (
        <>
          <WorkingIndicator />
          <Skeleton className="mb-2" height={"20rem"} />
        </>
      ) : RedirectState.REDIRECT === props.redirectState ? (
        <>
          <h2>{props.messageHeading}</h2>
          <p>{props.message}</p>
          <p>
            <a href={props.redirectUrl}>{t('redirect_now')}</a>
          </p>
        </>
      ) : props.children
          
      }
    </Panel>
  );
}

export { RedirectState };