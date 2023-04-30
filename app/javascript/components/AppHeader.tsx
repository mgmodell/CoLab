import React, { useState, useEffect, Suspense } from "react";
import PropTypes from "prop-types";
import AppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";

import Logo from "./Logo";
import MainMenu from "./MainMenu";
import HelpMenu from "./HelpMenu";
import Quote from "./Quote";
import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";
import Skeleton from "@mui/material/Skeleton";
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function AppHeader(props) {
  const { t, i18n } = useTranslation();
  const endpointSet = "home";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  return (
    <React.Fragment>
      <AppBar id="title_head" position="fixed">
        <Toolbar>
          <Suspense
            fallback={<Skeleton variant="rectangular" width={32} height={32} />}
          >
              <MainMenu
                diversityScoreFor={endpoints.diversityScoreFor}
                reportingUrl={endpoints.reportingUrl}
                supportAddress={endpoints.supportAddress}
                moreInfoUrl={endpoints.moreInfoUrl}
              />
          </Suspense>
          <Logo height={32} width={32} />

            <Suspense fallback={<Skeleton variant="text" />}>
              <Typography>
                {t("title")}
                <br />
                <Quote url={endpoints.quotePath} />
              </Typography>
            </Suspense>
          <Suspense fallback={<Skeleton variant={'circular'} />} >
            <HelpMenu lookupUrl={endpoints.lookupsUrl} />
          </Suspense>
        </Toolbar>
      </AppBar>
      <Toolbar />
    </React.Fragment>
  );
}

AppHeader.propTypes = {};
