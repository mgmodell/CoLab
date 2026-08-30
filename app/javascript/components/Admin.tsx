import React, { Suspense, useEffect } from "react";
import { Route, Routes, Navigate, Outlet, useLocation } from "react-router";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import { Skeleton } from "primereact/skeleton";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { useTour } from "./infrastructure/TourContext";

import CourseAdmin from "./course_admin/CourseAdmin";
import SchoolList from "./course_admin/SchoolList";
import UsersDataAdmin from "./course_admin/UsersDataAdmin";
import SchoolDataAdmin from "./course_admin/SchoolDataAdmin";
import RubricList from "./assignments/RubricList";
import RubricDataAdmin from "./assignments/RubricDataAdmin";
import ConsentFormList from "./Consent/ConsentFormList";
import ConsentFormDataAdmin from "./Consent/ConsentFormDataAdmin";
import ConceptsTable from "./ConceptsTable";
import { useTranslation } from "react-i18next";

//interface AdminProps {}

export default function Admin( /*props: AdminProps */) {
  const user = useTypedSelector(state => state.profile.user);
  const { setTourSteps } = useTour();
  const location = useLocation();
  const [t] = useTranslation();

  useEffect(() => {
    let description = t("home.admin_help");

    if (location.pathname.includes("/admin/courses")) {
      description = t("home.admin_help_courses");
    } else if (location.pathname.includes("/admin/rubrics")) {
      description = t("home.admin_help_rubrics");
    } else if (location.pathname.includes("/admin/concepts")) {
      description = t("home.admin_help_concepts");
    } else if (location.pathname.includes("/admin/users")) {
      description = t("home.admin_help_users");
    } else if (location.pathname.includes("/admin/schools")) {
      description = t("home.admin_help_schools");
    } else if (location.pathname.includes("/admin/consent_forms")) {
      description = t("home.admin_help_consent_forms");
    }

    setTourSteps([
      {
        element: "body",
        popover: {
          title: t("home.admin_help_title"),
          description,
          align: "center",
          side: "left"
        }
      }
    ]);

    return () => setTourSteps([]);
  }, [location.pathname, setTourSteps, t]);

  return (
    <Routes>
      {user.is_instructor || user.is_admin || user.researcher ? (
          <Route
            path={`users`}
            element={<UsersDataAdmin />}
          />
      ) : (
        <Route path={`/*`} element={<Navigate to="/" replace />} />
      )}
      {user.is_instructor || user.is_admin ? (
        <Route
          element={
            <React.Fragment>
              <WorkingIndicator identifier="admin_save" />
              <Suspense fallback={<Skeleton className="mb-2" />}>
                <Outlet />
              </Suspense>
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
