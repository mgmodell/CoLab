import React, { Suspense } from "react";

import MainMenu from "./MainMenu";
import HelpMenu from "./HelpMenu";
import Quote from "./Quote";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { Toolbar } from "primereact/toolbar";
import { Skeleton } from "primereact/skeleton";

export default function AppHeader(props) {
  const { t, i18n } = useTranslation();
  const endpointSet = "home";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const working = useTypedSelector(state => {
    let accum = 0;
    if (undefined === props.identifier) {
      accum = state.status.tasks[props.identifier];
    } else {
      accum = Number(
        Object.values(state.status.tasks).reduce((accum, nextVal) => {
          return Number(accum) + Number(nextVal);
        }, accum)
      );
    }
    return accum > 0;
  });

  return (
    <React.Fragment>
      <Toolbar
        className="mainNav"
        start={(
          endpoints !== undefined ? (
            <MainMenu
              diversityScoreFor={endpoints.diversityScoreFor}
              reportingUrl={endpoints.reportingUrl}
              supportAddress={endpoints.supportAddress}
              moreInfoUrl={endpoints.moreInfoUrl}
            />
          ) : (
            <Skeleton className="mb-2" width={'10rem'} height={'10rem'} />
          )
        )}
        center={(
          endpoints !== undefined ? (
            <>
              {t("title")}
              <br />
              <Quote url={endpoints.quotePath} />
            </>

          ) : (
            <Skeleton className="mb-2" width={'10rem'} height={'10rem'} />
          )
        )}
        end={(
          <Suspense fallback={<Skeleton className="mr-2" shape={'circle'} />} >
            <HelpMenu lookupUrl={endpoints?.lookupsUrl} />
          </Suspense>

        )}
      />
    </React.Fragment>
  );
}
