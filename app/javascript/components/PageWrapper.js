import React, { useEffect, useState, Suspense } from "react";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import {Provider} from 'react-redux';
import { createStore, applyMiddleware, compose } from 'redux';
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
import EnrollInCourse from './EnrollInCourse';
//import Auth from 'j-toker'
import ProtectedRoute from './infrastructure/ProtectedRoute';
import AppInit from './infrastructure/AppInit'

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;


export default function PageWrapper(props) {
  const store = createStore(appStatus, /* preloadedState, */ composeEnhancers(
      applyMiddleware( thunk ) 
    ));
  
  return (
    <Provider store={store}>
      <AppInit
          endpointsUrl={props.getEndpointsUrl}
      >
    <Router>
      <Suspense fallback={<Skeleton variant="rect" height={50} />}>
        <AppHeader
        />
      </Suspense>
      <br />
      <AppStatusBar />

      <Suspense fallback={<Skeleton variant="rect" height={600} />}>
        <Switch>
          <ProtectedRoute path="/profile">
            <ProfileDataAdmin
            />
          </ProtectedRoute>
          <Route path="/demo">
            <DemoWrapper
            />
          </Route>
          <ProtectedRoute path="/admin">
            <Admin
            />
          </ProtectedRoute>
          <ProtectedRoute
            path={`/submit_installment/:id`}
            render={routeProps => (
              <React.Fragment>
                <InstallmentReport
                  installmentId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          {/* Perhaps subgroup under Bingo */}
          <ProtectedRoute
            path={`/enter_candidates/:id`}
            render={routeProps => (
              <React.Fragment>
                <CandidateListEntry
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
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <ProtectedRoute
            path={`/score_bingo/:id`}
            render={routeProps => (
              <React.Fragment>
                Score the Bingo Component
              </React.Fragment>
            )}
          />
          {/* Perhaps subgroup under Bingo */}
          <ProtectedRoute
            path={`/experience/:id`}
            render={routeProps => (
              <React.Fragment>
                <Experience
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
                  consentFormId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <ProtectedRoute
            path={`/course/:course_id/confirm`}
            render={routeProps => (
              <React.Fragment>
                Confirm me in #{routeProps.match.params.course_id}
              </React.Fragment>
            )}
          />
          <ProtectedRoute
            path={`/course/:course_id/enroll`}
            render={routeProps => (
              <React.Fragment>
                <EnrollInCourse
                  courseId={Number(routeProps.match.params.course_id)}
                  />
              </React.Fragment>
            )}
          />
          <ProtectedRoute exact path="/"
            render={routeProps =>(
              <React.Fragment>
                <HomeShell />
              </React.Fragment>
            ) }
          />
          <Route path='/login'
            render={routeProps => (
                  <SignIn {...routeProps} />
            )}
          />
        </Switch>
      </Suspense>
    </Router>
        </AppInit>

    </Provider>
  );
}

PageWrapper.propTypes = {
};
