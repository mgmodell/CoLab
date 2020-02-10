import React, { useState, useEffect, Suspense } from "react";
import PropTypes from "prop-types";
import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Typography";

import MainMenu from "./MainMenu";
import Quote from "./Quote";
import {i18n} from "./i18n"
import { useTranslation } from "react-i18next";
import Skeleton from "@material-ui/lab/Skeleton";

export default function AppHeader(props) {
  const {t, i18n} = useTranslation()
  const [endpoints, setEndpoints] = useState({})
  const [loaded, setLoaded] = useState( false );

  useEffect(() => getEndpoints(), []);

  const getEndpoints = () =>{
    fetch(props.getEndpointsUrl + ".json", {
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
        return response.json();
      } else {
        console.log("error");
      }
    })
    .then(data => {
      setEndpoints(data);
      setLoaded( true );
    } );
  }


  return (
    <React.Fragment>
      <AppBar id="title_head" position="fixed">
        <Toolbar>
          <Suspense fallback={<Skeleton
          variant="rect" width={32} height={32}/>}>

          {loaded ? 
          (<MainMenu
            token={props.token}
            homeUrl={endpoints.homeUrl}
            profileUrl={endpoints.profileUrl}
            diversityScoreFor={endpoints.diversityScoreFor}
            adminUrl={endpoints.adminUrl}
            coursesUrl={endpoints.coursesPath}
            schoolsUrl={endpoints.schoolsPath}
            conceptsUrl={endpoints.conceptsPath}
            reportingUrl={endpoints.reportingUrl}
            demoUrl={endpoints.demoUrl}
            logoutUrl={endpoints.logoutUrl}
            supportAddress={endpoints.supportAddress}
            moreInfoUrl={endpoints.moreInfoUrl}
          />) : 
          (<Skeleton variant="rect" width={32} height={32} />) }
          </Suspense>
          {loaded ?
          (<Suspense fallback={<Skeleton variant='rect' width={32} height={32}/>}>
            <img
              src={endpoints.logoPath}
              style={{ width: 32, height: 32 }}
              alt="CoLab Logo"
            />
          </Suspense>)
          : 
          (<Skeleton variant="rect" width={32} height={32} />) }

          {loaded ?
          (<Suspense fallback={<Skeleton variant='text' />} >
          <Typography>
            {t( 'title' )}
            <br/>
            <Quote token={props.token} url={endpoints.quotePath} />
          </Typography> 

          </Suspense>) :
          (<Skeleton variant='text' />)}

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
