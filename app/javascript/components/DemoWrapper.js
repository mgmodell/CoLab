import React, { Suspense } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  useMatch
} from "react-router-dom";
import Skeleton from "@mui/material/Skeleton";

const HomeShell = React.lazy(() => import("./HomeShell"));
const InstallmentReport = React.lazy(() => import("./InstallmentReport"));
const CandidateListEntry = React.lazy(() =>
  import("./BingoBoards/CandidateListEntry")
);
const CandidatesReviewTable = React.lazy(() =>
  import("./BingoBoards/CandidatesReviewTable")
);
const BingoBuilder = React.lazy(() => import("./BingoBoards/BingoBuilder"));
const Experience = React.lazy(() => import("./Experience"));
const ConsentLog = React.lazy(() => import("./Consent/ConsentLog"));

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
