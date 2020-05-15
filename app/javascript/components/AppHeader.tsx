import React, { useState, useEffect, Suspense } from "react";
import PropTypes from "prop-types";
import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Typography";

import MainMenu from "./MainMenu";
import HelpMenu from "./HelpMenu";
import Quote from "./Quote";
import { i18n } from "./i18n";
import { useTranslation } from "react-i18next";
import Skeleton from "@material-ui/lab/Skeleton";
import { useEndpointStore } from "./EndPointStore";

export default function AppHeader(props) {
  const { t, i18n } = useTranslation();
  //const [endpoints, setEndpoints] = useState({})
  const endpointSet = "home";
  const [endpoints, endpointsActions] = useEndpointStore();

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
  }, []);

  return (
    <React.Fragment>
      <AppBar id="title_head" position="fixed">
        <Toolbar>
          <Suspense
            fallback={<Skeleton variant="rect" width={32} height={32} />}
          >
            {endpoints.endpointStatus["home"] == "loaded" ? (
              <MainMenu
                token={props.token}
                homeUrl={endpoints.endpoints["home"].homeUrl}
                profileUrl={endpoints.endpoints["home"].profileUrl}
                diversityScoreFor={
                  endpoints.endpoints["home"].diversityScoreFor
                }
                adminUrl={endpoints.endpoints["home"].adminUrl}
                coursesUrl={endpoints.endpoints["home"].coursesPath}
                schoolsUrl={endpoints.endpoints["home"].schoolsPath}
                consentFormsUrl={endpoints.endpoints['home'].consentFormsPath}
                conceptsUrl={endpoints.endpoints["home"].conceptsPath}
                reportingUrl={endpoints.endpoints["home"].reportingUrl}
                demoUrl={endpoints.endpoints["home"].demoUrl}
                logoutUrl={endpoints.endpoints["home"].logoutUrl}
                supportAddress={endpoints.endpoints["home"].supportAddress}
                moreInfoUrl={endpoints.endpoints["home"].moreInfoUrl}
              />
            ) : (
              <Skeleton variant="rect" width={32} height={32} />
            )}
          </Suspense>
          {endpoints.endpointStatus["home"] == "loaded" ? (
            <Suspense
              fallback={<Skeleton variant="rect" width={32} height={32} />}
            >
              <img
                src={endpoints.endpoints["home"].logoPath}
                style={{ width: 32, height: 32 }}
                alt="CoLab Logo"
              />
            </Suspense>
          ) : (
            <Skeleton variant="rect" width={32} height={32} />
          )}

          {endpoints.endpointStatus["home"] == "loaded" ? (
            <Suspense fallback={<Skeleton variant="text" />}>
              <Typography>
                {t("title")}
                <br />
                <Quote
                  token={props.token}
                  url={endpoints.endpoints["home"].quotePath}
                />
              </Typography>
            </Suspense>
          ) : (
            <Skeleton variant="text" />
          )}
          <HelpMenu token={props.token} />
        </Toolbar>
      </AppBar>
      <Toolbar />
    </React.Fragment>
  );
}

AppHeader.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
