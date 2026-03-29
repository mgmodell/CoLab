import React, { useEffect } from "react";
import { Route, Routes, Navigate, Outlet } from "react-router-dom";
import WorkingIndicator from "./infrastructure/WorkingIndicator";

import CourseAdmin from "./course_admin/CourseAdmin";
import SchoolList from "./course_admin/SchoolList";
import SchoolDataAdmin from "./course_admin/SchoolDataAdmin";
import RubricList from "./assignments/RubricList";
import RubricDataAdmin from "./assignments/RubricDataAdmin";
import ConsentFormList from "./Consent/ConsentFormList";
import ConsentFormDataAdmin from "./Consent/ConsentFormDataAdmin";
import ConceptsTable from "./ConceptsTable";

import { useTypedSelector } from "./infrastructure/AppReducers";

interface AdminProps {}

export default function Admin(props: AdminProps) {
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
