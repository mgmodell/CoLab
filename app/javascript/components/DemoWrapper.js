import React, { useState, Suspense } from "react";
import {
  BrowserRouter as Router,
  Switch,
  Route,
  useRouteMatch
} from "react-router-dom";
import Skeleton from "@material-ui/lab/Skeleton";
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
  let { path, url } = useRouteMatch();

  return (
    <Router>
      <Suspense fallback={<Skeleton variant="rect" height={600} />}>
        <Switch>
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
                <Experience
                  experienceId={Number(routeProps.match.params.id)}
                />
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
            <HomeShell
            />
          </Route>
        </Switch>
      </Suspense>
    </Router>
  );
}

DemoWrapper.propTypes = {
};