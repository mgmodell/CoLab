import React, { useState, useEffect, Suspense } from "react";
import PropTypes from "prop-types";
import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Typography";

import Logo from "./Logo";
import MainMenu from "./MainMenu";
import HelpMenu from "./HelpMenu";
import Quote from "./Quote";
import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";
import Skeleton from "@material-ui/lab/Skeleton";
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function AppHeader(props) {
  const { t, i18n } = useTranslation();
  const endpointSet = "home";
  const endpoints = useTypedSelector( state =>state['context'].endpoints[endpointSet])
  const endpointsLoaded = useTypedSelector( state =>state['context']['status']['endpointsLoaded']  );

  return (
    <React.Fragment>
      <AppBar id="title_head" position="fixed">
        <Toolbar>
          <Suspense
            fallback={<Skeleton variant="rect" width={32} height={32} />}
          >
            {endpointsLoaded ? (
              <MainMenu
                diversityScoreFor={
                  endpoints.diversityScoreFor
                }
                reportingUrl={endpoints.reportingUrl}
                supportAddress={endpoints.supportAddress}
                moreInfoUrl={endpoints.moreInfoUrl}
              />
            ) : (
              <Skeleton variant="rect" width={32} height={32} />
            )}
          </Suspense>
            <Logo height={32} width={32}/>

            { endpointsLoaded ? (
            <Suspense fallback={<Skeleton variant="text" />}>
              <Typography>
                {t("title")}
                <br />
                <Quote
                  url={endpoints.quotePath}
                />
              </Typography>
            </Suspense>
          ) : (
            <Skeleton variant="text" />
          )}
            {endpointsLoaded ? (
            <HelpMenu
              lookupUrl={endpoints.lookupsUrl}
            />
          ) : (
            <Skeleton variant="circle" />
          )}
        </Toolbar>
      </AppBar>
      <Toolbar />
    </React.Fragment>
  );
}

AppHeader.propTypes = {
};
