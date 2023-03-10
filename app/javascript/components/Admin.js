import React, { useState, useEffect } from "react";
import { Route, Routes, Navigate } from "react-router-dom";
import { Settings } from "luxon";
import WorkingIndicator from "./infrastructure/WorkingIndicator";

import CourseAdmin from "./CourseAdmin";
const SchoolList = React.lazy(() => import("./SchoolList"));
const SchoolDataAdmin = React.lazy(() => import("./SchoolDataAdmin"));
const ConsentFormList = React.lazy(() => import("./Consent/ConsentFormList"));
const ConsentFormDataAdmin = React.lazy(() =>
  import("./Consent/ConsentFormDataAdmin")
);
const ConceptsTable = React.lazy(() => import("./ConceptsTable"));
const ReportingAdmin = React.lazy(() => import("./Reports/ReportingAdmin"));

import { useTypedSelector } from "./infrastructure/AppReducers";

export default function Admin(props) {
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );

  const [showErrors, setShowErrors] = useState(false);

  const [working] = useState(true);

  useEffect(() => {
    if (null !== user.lastRetrieved && null !== tz_hash) {
      Settings.defaultZoneName = tz_hash[user.timezone];
    }
  }, [user.lastRetrieved, tz_hash]);

  return (
    <React.Fragment>
      <WorkingIndicator id="admin_save" />
      <Routes>
        {user.is_instructor || user.is_admin ? (
          <React.Fragment>
            <Route path={`courses/*`} element={<CourseAdmin />} />
            <Route exact path={`schools`} element={<SchoolList />} />
            <Route
              path={`schools/:schoolIdParam`}
              element={<SchoolDataAdmin />}
            />
            <Route exact path={`consent_forms`} element={<ConsentFormList />} />
            <Route
              path={`consent_forms/:consentFormIDParam`}
              element={<ConsentFormDataAdmin />}
            />
            <Route path={`concepts`} element={<ConceptsTable />} />
            <Route path={"reporting"} element={<ReportingAdmin />} />
            <Route path={`/`} element={<Navigate to="courses" replace />} />
          </React.Fragment>
        ) : (
          <Route path={`/*`} element={<Navigate to="/" replace />} />
        )}
      </Routes>
    </React.Fragment>
  );
}

Admin.propTypes = {};
