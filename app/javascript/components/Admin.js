import React, { useState, useEffect } from "react";
import { Route, Routes, Navigate } from "react-router-dom";
import PropTypes from "prop-types";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Settings from "luxon/src/settings.js";

import CloseIcon from "@mui/icons-material/Close";
import SchoolList from "./SchoolList";
import CourseAdmin from "./CourseAdmin";
import SchoolDataAdmin from "./SchoolDataAdmin";
import ConsentFormList from "./Consent/ConsentFormList";
import ConsentFormDataAdmin from "./Consent/ConsentFormDataAdmin";
import ConceptsTable from "./ConceptsTable";
import ReportingAdmin from "./Reports/ReportingAdmin";

import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function Admin(props) {
  const user = useTypedSelector(state => state.profile.user);

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
        <Route path={`courses/*`} element={<CourseAdmin />} />
        <Route exact path={`schools`} element={<SchoolList />} />
        <Route path={`schools/:schoolIdParam`} element={<SchoolDataAdmin />} />
        <Route exact path={`consent_forms`} element={<ConsentFormList />} />
        <Route
          path={`consent_forms/:consentFormIDParam`}
          element={<ConsentFormDataAdmin />}
        />
        <Route path={`concepts`} element={<ConceptsTable />} />
        <Route path={"reporting"} element={<ReportingAdmin />} />
        <Route path={`/`} element={<Navigate to="courses" replace />} />
      </Routes>
    </React.Fragment>
  );
}

Admin.propTypes = {};
