import React, { useState, Suspense } from "react";
import { BrowserRouter as Router,
  Switch, Route, Link } from "react-router-dom";
import Skeleton from "@material-ui/lab/Skeleton";
import PropTypes from "prop-types";
import AppHeader from "./AppHeader";

import HomeShell from './HomeShell';



export default function PageWrapper(props) {
  const [helpTopic, setHelpTopic] = useState("");

  return (
    <Router>
      <Suspense fallback={<Skeleton variant="rect" height={50} />}>
        <AppHeader token={props.token} getEndpointsUrl={props.getEndpointsUrl} />
      </Suspense>
      <br/><br/>
      <Suspense fallback={<Skeleton variant='rect' height={600} />} >
        <Switch >
          <Route path='/'>
            <HomeShell
              token={props.token}
              getEndpointsUrl={props.getEndpointsUrl} />
          </Route>
          <Route path='installments'>
            Some installments stuff

          </Route>
    
        </Switch>

      </Suspense>

    </Router>

  );
}

PageWrapper.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
