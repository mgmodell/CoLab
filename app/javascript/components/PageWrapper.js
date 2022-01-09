import React, { useEffect, useState, Suspense } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
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
        <Routes>
          <Route path="profile" element={
            <RequireAuth>
              <ProfileDataAdmin />
            </RequireAuth>
          } />
          <Route path="demo" element={
            <DemoWrapper
            />
          }/>
          <Route path="admin/*" element={
            <RequireAuth>
            <Admin
            />
            </RequireAuth>

          } />
          <Route
            path={`submit_installment/:installmentId`}
            element={
              <RequireAuth>
                <InstallmentReport
                />
              </RequireAuth>
            }
          />
          {/* Perhaps subgroup under Bingo */}
          <Route
            path={`enter_candidates/:bingoGameId`}
            element={
              <RequireAuth>
                <CandidateListEntry
                />
              </RequireAuth>
            }
          />
          <Route
            path={`review_candidates/:bingoGameId`}
            element={
              <RequireAuth>
                <CandidatesReviewTable
                />
              </RequireAuth>
            }
          />
          <Route
            path={`candidate_results/:bingoGameId`}
            element={
              <RequireAuth>
                <BingoBuilder
                />
              </RequireAuth>
            }
          />
          <Route
            path={`score_bingo/:id`}
            element={
              <RequireAuth>
                Score the Bingo Component
              </RequireAuth>
            }
          />
          {/* Perhaps subgroup under Bingo */}
          <Route
            path={`experience/:experienceId`}
            element={
              <RequireAuth>
                <Experience
                />
              </RequireAuth>
            }
          />
          <Route
            path={`research_information/:consentFormId`}
            element={
              <RequireAuth>
                <ConsentLog
                />
              </RequireAuth>
            }
          />
          <Route
            path={`course/:course_id/confirm`}
            element={
              <RequireAuth>
                Confirm me, please - this must be built.
              </RequireAuth>
            }
          />
          <Route
            path={`course/:courseId/enroll`}
            element={
              <RequireAuth>
                <EnrollInCourse
                  />
              </RequireAuth>
            }
          />
          <Route path="/"
            element={
              <RequireAuth>
                <HomeShell />
              </RequireAuth>
            }
          />
          <Route path='login'
            element={
                  <SignIn />
            }
          />
        </Routes>
      </Suspense>
    </Router>
        </AppInit>

    </Provider>
  );
}

PageWrapper.propTypes = {
};
