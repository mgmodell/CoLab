import React, { useState, useEffect } from "react";
import {
  Route,
  Switch,
  Redirect,
  useRouteMatch,
  useParams
} from "react-router-dom";
import PropTypes from "prop-types";
import Alert from "@material-ui/lab/Alert";
import IconButton from "@material-ui/core/IconButton";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Settings from "luxon/src/settings.js";

import CloseIcon from "@material-ui/icons/Close";
import SchoolList from "./SchoolList";
import CourseAdmin from "./CourseAdmin";
import SchoolDataAdmin from "./SchoolDataAdmin";
import ConsentFormList from "./Consent/ConsentFormList";
import ConsentFormDataAdmin from "./Consent/ConsentFormDataAdmin";
import ConceptsTable from './ConceptsTable';

import Collapse from "@material-ui/core/Collapse";
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function Admin(props) {
  let { path, url } = useRouteMatch();

  const user = useTypedSelector((state)=>state.profile.user)

  const [showErrors, setShowErrors] = useState(false);

  const [working] = useState(true);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  return (
    <React.Fragment>
      <WorkingIndicator id="admin_save" />
      <Switch>
        <Route path={`${path}/courses`}>
          <CourseAdmin />
        </Route>
        <Route exact path={`${path}/schools`}>
          <SchoolList />
        </Route>
        <Route path={`${path}/schools/:id`}>
          <SchoolDataAdmin
          />
        </Route>
        <Route exact path={`${path}/consent_forms`}>
          <ConsentFormList />
        </Route>
        <Route path={`${path}/consent_forms/:id`}>
          <ConsentFormDataAdmin
          />
        </Route>
        <Route path={`${path}/concepts`}>
          <ConceptsTable />
        </Route>
        <Route path={`${path}`}>
          <Redirect to={`${path}/courses`} />
        </Route>
      </Switch>
    </React.Fragment>
  );
}

Admin.propTypes = {
};
