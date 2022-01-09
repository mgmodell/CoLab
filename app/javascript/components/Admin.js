import React, { useState, useEffect } from "react";
import {
  Route,
  Routes,
  Navigate,
  useMatch,
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
  let { path, url } = useMatch();

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
      <Routes>
        <Route path={`courses/*`}
          element={ <CourseAdmin /> }
        />
        <Route exact path={`schools`}
          element={ <SchoolList /> }
          />
        <Route path={`schools/:schoolIdParam`}
          element={ <SchoolDataAdmin /> }
        />
        <Route exact path={`consent_forms`}
          element={
            <ConsentFormList />
          } />
        <Route path={`consent_forms/:consentFormIDParam`}
          element={
            <ConsentFormDataAdmin />
          } />
        <Route path={`concepts`}
          element={
            <ConceptsTable />
          } />
        <Route path={`/`}
          element={
            <Navigate to={`${path}/courses`} replace />

          }/>
      </Routes>
    </React.Fragment>
  );
}

Admin.propTypes = {
};
