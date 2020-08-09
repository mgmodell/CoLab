import React, { useEffect, useState, Suspense } from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import {Provider} from 'react-redux';
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import appStatus from './infrastructure/AppReducers';

import Skeleton from "@material-ui/lab/Skeleton";
import PropTypes from "prop-types";
import AppHeader from "./AppHeader";

import HomeShell from "./HomeShell";
import ProfileDataAdmin from "./ProfileDataAdmin";
import InstallmentReport from "./InstallmentReport";
import CandidateListEntry from "./BingoBoards/CandidateListEntry";
import CandidatesReviewTable from "./BingoBoards/CandidatesReviewTable";
import BingoBuilder from "./BingoBoards/BingoBuilder";
import Experience from "./Experience";
import ConsentLog from "./Consent/ConsentLog";
import Admin from "./Admin";
import DemoWrapper from "./DemoWrapper";
import AppStatusBar from "./AppStatusBar";
import SignIn from './SignIn';
//import Auth from 'j-toker'
import ProtectedRoute from './infrastructure/ProtectedRoute';
import AuthInit from './infrastructure/AuthInit'

const composeEnhancer = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;


export default function PageWrapper(props) {
  const store = createStore(appStatus,
    composeEnhancer( applyMiddleware( thunk ) ) );
  
  return (
    <Provider store={store}>
      <AuthInit />

    <Router>
      <Suspense fallback={<Skeleton variant="rect" height={50} />}>
        <AppHeader
          token={props.token}
          getEndpointsUrl={props.getEndpointsUrl}
        />
      </Suspense>
      <br />
      <AppStatusBar />

      <Suspense fallback={<Skeleton variant="rect" height={600} />}>
        <Switch>
          <ProtectedRoute path="/profile">
            <ProfileDataAdmin
              token={props.token}
              getEndpointsUrl={props.getEndpointsUrl}
            />
          </ProtectedRoute>
          <Route path="/demo">
            <DemoWrapper
              token={props.token}
              getEndpointsUrl={props.getEndpointsUrl}
            />
          </Route>
          <ProtectedRoute path="/admin">
            <Admin
              token={props.token}
              getEndpointsUrl={props.getEndpointsUrl}
            />
          </ProtectedRoute>
          <ProtectedRoute
            path={`/submit_installment/:id`}
            render={routeProps => (
              <React.Fragment>
                <InstallmentReport
                  token={props.token}
                  getEndpointsUrl={props.getEndpointsUrl}
                  installmentId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <ProtectedRoute
            path={`/enter_candidates/:id`}
            render={routeProps => (
              <React.Fragment>
                <CandidateListEntry
                  token={props.token}
                  getEndpointsUrl={props.getEndpointsUrl}
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <ProtectedRoute
            path={`/review_candidates/:id`}
            render={routeProps => (
              <React.Fragment>
                <CandidatesReviewTable
                  token={props.token}
                  getEndpointsUrl={props.getEndpointsUrl}
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <ProtectedRoute
            path={`/candidate_results/:id`}
            render={routeProps => (
              <React.Fragment>
                <BingoBuilder
                  token={props.token}
                  getEndpointsUrl={props.getEndpointsUrl}
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <ProtectedRoute
            path={`/experience/:id`}
            render={routeProps => (
              <React.Fragment>
                <Experience
                  token={props.token}
                  getEndpointsUrl={props.getEndpointsUrl}
                  experienceId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <ProtectedRoute
            path={`/research_information/:id`}
            render={routeProps => (
              <React.Fragment>
                <ConsentLog
                  token={props.token}
                  getEndpointsUrl={props.getEndpointsUrl}
                  consentFormId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <ProtectedRoute exact path="/"
            render={routeProps =>(
              <HomeShell
                token={props.token}
                getEndpointsUrl={props.getEndpointsUrl}
              />
            ) }
          />
          <Route path='/login'
            render={routeProps => (
                  <SignIn />
            )}
          />
        </Switch>
      </Suspense>
    </Router>
    </Provider>
  );
}

PageWrapper.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
