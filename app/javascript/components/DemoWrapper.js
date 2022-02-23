import React, { useState, Suspense } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  useMatch
} from "react-router-dom";
import Skeleton from "@mui/material/Skeleton";
import PropTypes from "prop-types";
import AppHeader from "./AppHeader";
import Joyride from "react-joyride";

import HomeShell from "./HomeShell";
import ProfileDataAdmin from "./ProfileDataAdmin";
import InstallmentReport from "./InstallmentReport";
import CandidateListEntry from "./BingoBoards/CandidateListEntry";
import CandidatesReviewTable from "./BingoBoards/CandidatesReviewTable";
import BingoBuilder from "./BingoBoards/BingoBuilder";
import Experience from "./Experience";
import ConsentLog from "./Consent/ConsentLog";
import Admin from "./Admin";
import AppStatusBar from "./AppStatusBar";

export default function DemoWrapper(props) {
  let { path, url } = useMatch();

  return (
    <Router>
      <Suspense fallback={<Skeleton variant="rectangular" height={600} />}>
        <Routes>
          <Route
            path={`${path}/submit_installment/:id`}
            render={routeProps => (
              <React.Fragment>
                <InstallmentReport
                  installmentId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <Route
            path={`${path}/enter_candidates/:id`}
            render={routeProps => (
              <React.Fragment>
                <CandidateListEntry
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <Route
            path={`${path}/review_candidates/:id`}
            render={routeProps => (
              <React.Fragment>
                <CandidatesReviewTable
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <Route
            path={`${path}/candidate_results/:id`}
            render={routeProps => (
              <React.Fragment>
                <BingoBuilder
                  bingoGameId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <Route
            path={`${path}/experience/:id`}
            render={routeProps => (
              <React.Fragment>
                <Experience experienceId={Number(routeProps.match.params.id)} />
              </React.Fragment>
            )}
          />
          <Route
            path={`${path}/research_information/:id`}
            render={routeProps => (
              <React.Fragment>
                <ConsentLog
                  consentFormId={Number(routeProps.match.params.id)}
                />
              </React.Fragment>
            )}
          />
          <Route exact path={`${path}/`}>
            <HomeShell />
          </Route>
        </Routes>
      </Suspense>
    </Router>
  );
}

DemoWrapper.propTypes = {};
