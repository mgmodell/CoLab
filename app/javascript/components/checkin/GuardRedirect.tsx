import React, { useEffect } from "react";
import { useNavigate } from "react-router";

import { Skeleton } from "primereact/skeleton";
import parse from 'html-react-parser';

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
  children: React.ReactNode;
}

export default function GuardRedirect(props: Props) {
  const category = "installment";
  const [t] = useTranslation(`${category}s`);
  const navigate = useNavigate();

  useEffect(() => {
    if( RedirectState.REDIRECT === props.redirectState && props.redirectUrl !== undefined ) {
      const timer = setTimeout(() => {
        navigate(props.redirectUrl);
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, [props.redirectUrl, props.redirectState, navigate]);


  return (
    <Panel>
      {RedirectState.DECIDING === props.redirectState ? (
        <Skeleton className="mb-2" height={"20rem"} />
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