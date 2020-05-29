import React, { useState, Suspense } from "react";
import { BrowserRouter as Router,
  Switch, Route } from "react-router-dom";
import Skeleton from "@material-ui/lab/Skeleton";
import PropTypes from "prop-types";
import AppHeader from "./AppHeader";

import HomeShell from './HomeShell';
import ProfileDataAdmin from './ProfileDataAdmin'
import InstallmentReport from './InstallmentReport';
import CandidateListEntry from './BingoBoards/CandidateListEntry';
import ConsentLog from './Consent/ConsentLog'
import Admin from './Admin'



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
          <Route path='/profile'>
            <ProfileDataAdmin
              token={props.token}
              getEndpointsUrl={props.getEndpointsUrl} />
          </Route>
          <Route path='/admin' >
            <Admin
              token={props.token}
              getEndpointsUrl={props.getEndpointsUrl}

            />

          </Route>
          <Route path={`/submit_installment/:id`}
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
          <Route path={`/enter_candidates/:id`}
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
          <Route path={`/research_information/:id`}
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
          <Route exact path='/'>
            <HomeShell
              token={props.token}
              getEndpointsUrl={props.getEndpointsUrl} />
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
