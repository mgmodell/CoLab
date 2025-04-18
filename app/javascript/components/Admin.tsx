import React, { useEffect } from "react";
import { Route, Routes, Navigate, Outlet } from "react-router";
import WorkingIndicator from "./infrastructure/WorkingIndicator";

import CourseAdmin from "./course_admin/CourseAdmin";
const SchoolList = React.lazy(() => import("./course_admin/SchoolList"));
const SchoolDataAdmin = React.lazy(() =>
  import("./course_admin/SchoolDataAdmin")
);
const RubricList = React.lazy(() => import("./assignments/RubricList"));
const RubricDataAdmin = React.lazy(() =>
  import("./assignments/RubricDataAdmin")
);
const ConsentFormList = React.lazy(() => import("./Consent/ConsentFormList"));
const ConsentFormDataAdmin = React.lazy(() =>
  import("./Consent/ConsentFormDataAdmin")
);
const ConceptsTable = React.lazy(() => import("./ConceptsTable"));

import { useTypedSelector } from "./infrastructure/AppReducers";

export default function Admin(props) {
  const user = useTypedSelector(state => state.profile.user);

  return (
    <Routes>
      {user.is_instructor || user.is_admin ? (
        <Route
          element={
            <React.Fragment>
              <WorkingIndicator identifier="admin_save" />
              <Outlet />
            </React.Fragment>
          }
        >
          <Route path={`courses/*`} element={<CourseAdmin />} />
          <Route path={`rubrics`} element={<RubricList />} />
          <Route
            path={`rubrics/:rubricIdParam`}
            element={<RubricDataAdmin />}
          />
          <Route path={`schools`} element={<SchoolList />} />
          <Route
            path={`schools/:schoolIdParam`}
            element={<SchoolDataAdmin />}
          />
          <Route path={`consent_forms`} element={<ConsentFormList />} />
          <Route
            path={`consent_forms/:consentFormIDParam`}
            element={<ConsentFormDataAdmin />}
          />
          <Route path={`concepts`} element={<ConceptsTable />} />
          <Route index element={<Navigate to="courses" replace />} />
        </Route>
      ) : (
        <Route path={`/*`} element={<Navigate to="/" replace />} />
      )}
    </Routes>
  );
}

Admin.propTypes = {};
