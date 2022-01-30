import React, { useEffect, useState, Suspense } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import {Provider} from 'react-redux';
import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import appStatus from './infrastructure/AppReducers';

import Skeleton from '@mui/material/Skeleton';
import { ThemeProvider, StyledEngineProvider, createTheme, adaptV4Theme } from "@mui/material";
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
import ScoreBingoWorksheet from './BingoBoards/ScoreBingoWorksheet';
import RequireAuth from './infrastructure/RequireAuth';
import Privacy from './Privacy';
import TermsOfService from './TermsOfService';
import AppInit from './infrastructure/AppInit';

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;


export default function PageWrapper(props) {
  const store = createStore(appStatus, /* preloadedState, */ composeEnhancers(
      applyMiddleware( thunk ) 
    ));

  const styles = createTheme({
    typography: {
      useNextVariants: true
    }
  });
  
  return (
    <Provider store={store}>
      <StyledEngineProvider injectFirst>
        <ThemeProvider theme={styles} >
        <AppInit
            endpointsUrl={props.getEndpointsUrl}
        >
      <Router>
        <Suspense fallback={<Skeleton variant="rectangular" height={50} />}>
          <AppHeader
          />
        </Suspense>
        <br />
        <AppStatusBar />

        <Suspense fallback={<Skeleton variant="rectangular" height={600} />}>
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
              path={`score_bingo_worksheet/:worksheetIdParam`}
              element={
                <RequireAuth>
                  <ScoreBingoWorksheet />
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
              path={`course/:courseId/enroll`}
              element={
                <RequireAuth>
                  <EnrollInCourse
                    />
                </RequireAuth>
              }
            />
            <Route
              path={`tos`}
              element={
                  <TermsOfService
                    />
              }
            />
            <Route
              path={`privacy`}
              element={
                  <Privacy
                    />
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

      </ThemeProvider>
      </StyledEngineProvider>
    </Provider>
  );
}

PageWrapper.propTypes = {
  getEndpointsUrl: PropTypes.string.isRequired
};
