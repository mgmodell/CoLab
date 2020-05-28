import React, { useState, useEffect } from "react";
import {
  Route,
  Switch,
  Redirect,
  useRouteMatch,
  useParams
} from 'react-router-dom';
import PropTypes from "prop-types";
import Alert from "@material-ui/lab/Alert";
import IconButton from "@material-ui/core/IconButton";
import LinearProgress from "@material-ui/core/LinearProgress";
import Settings from "luxon/src/settings.js";

import CloseIcon from "@material-ui/icons/Close";
import SchoolList from './SchoolList';
import CourseAdmin from './CourseAdmin';
import SchoolDataAdmin from './SchoolDataAdmin';
import ConsentFormList from './Consent/ConsentFormList';
import ConsentFormDataAdmin from './Consent/ConsentFormDataAdmin';

import {useUserStore} from "./infrastructure/UserStore";
import Collapse from "@material-ui/core/Collapse";

export default function Admin(props) {
  let {path, url} = useRouteMatch();

  const [user] = useUserStore();
  const [messages, setMessages] = useState({});

  const [showErrors, setShowErrors] = useState(false);

  const [working] = useState(true);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);


  let {id} = useParams( );

  return (
    <React.Fragment>
      <Collapse in={showErrors}>
        <Alert
          action={
            <IconButton
              aria-label="close"
              color="inherit"
              size="small"
              onClick={() => {
                setShowErrors(false);
              }}
            >
              <CloseIcon fontSize="inherit" />
            </IconButton>
          }
        >
          {messages["main"] || null}
        </Alert>
      </Collapse>
      {working ? <LinearProgress /> : null}
      <Switch>
        <Route path={`${path}/courses`}>
          <CourseAdmin
            token={props.token}
            getEndpointsUrl={props.getEndpointsUrl}
            />

        </Route>
        <Route exact path={`${path}/schools`}>
          <SchoolList
            token={props.token}
            getEndpointsUrl={props.getEndpointsUrl}
            />

        </Route>
        <Route path={`${path}/schools/:id`}>
          <SchoolDataAdmin
            token={props.token}
            getEndpointsUrl={props.getEndpointsUrl}
            schoolId={'new' === id ? null : id }
            />

        </Route>
        <Route exact path={`${path}/consent_forms`}>
          <ConsentFormList
            token={props.token}
            getEndpointsUrl={props.getEndpointsUrl}
            />

        </Route>
        <Route path={`${path}/consent_forms/:id`}>
          <ConsentFormDataAdmin
            token={props.token}
            getEndpointsUrl={props.getEndpointsUrl}
            schoolId={id === 'new' ? null : id }
            />

        </Route>
        <Route path={`${path}`} >
          <Redirect to={`${path}/courses`} />
        </Route>
      </Switch>
    </React.Fragment>
  );
}

Admin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
