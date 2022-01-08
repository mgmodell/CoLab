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
import RequireAuth from './infrastructure/RequireAuth';
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
          <Route path="/profile">
            <RequireAuth>
              <ProfileDataAdmin
              />
            </RequireAuth>
          </Route>
          <Route path="/demo">
            <DemoWrapper
            />
          </Route>
          <Route path="/admin">
            <RequireAuth>
            <Admin
            />
            </RequireAuth>
          </Route>
          <Route
            path={`/submit_installment/:id`}
            render={routeProps => (
              <RequireAuth>
                <InstallmentReport
                  installmentId={Number(routeProps.match.params.id)}
                />
              </RequireAuth>
            )}
          />
          {/* Perhaps subgroup under Bingo */}
          <Route
            path={`/enter_candidates/:id`}
            render={routeProps => (
              <RequireAuth>
                <CandidateListEntry
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </RequireAuth>
            )}
          />
          <Route
            path={`/review_candidates/:id`}
            render={routeProps => (
              <RequireAuth>
                <CandidatesReviewTable
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </RequireAuth>
            )}
          />
          <Route
            path={`/candidate_results/:id`}
            render={routeProps => (
              <RequireAuth>
                <BingoBuilder
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </RequireAuth>
            )}
          />
          <Route
            path={`/score_bingo/:id`}
            render={routeProps => (
              <RequireAuth>
                Score the Bingo Component
              </RequireAuth>
            )}
          />
          {/* Perhaps subgroup under Bingo */}
          <Route
            path={`/experience/:id`}
            render={routeProps => (
              <RequireAuth>
                <Experience
                  experienceId={Number(routeProps.match.params.id)}
                />
              </RequireAuth>
            )}
          />
          <Route
            path={`/research_information/:id`}
            render={routeProps => (
              <RequireAuth>
                <ConsentLog
                  consentFormId={Number(routeProps.match.params.id)}
                />
              </RequireAuth>
            )}
          />
          <Route
            path={`/course/:course_id/confirm`}
            render={routeProps => (
              <RequireAuth>
                Confirm me in #{routeProps.match.params.course_id}
              </RequireAuth>
            )}
          />
          <Route
            path={`/course/:course_id/enroll`}
            render={routeProps => (
              <RequireAuth>
                <EnrollInCourse
                  courseId={Number(routeProps.match.params.course_id)}
                  />
              </RequireAuth>
            )}
          />
          <Route exact path="/"
            render={routeProps =>(
              <RequireAuth>
                <HomeShell />
              </RequireAuth>
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
