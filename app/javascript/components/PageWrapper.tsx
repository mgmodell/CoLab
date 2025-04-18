import React, { Suspense } from "react";
import { RouterProvider } from 'react-router/dom';
import {
  createBrowserRouter,
  Route,
  createRoutesFromElements,
  Outlet,
  Navigate
} from "react-router";
import { Provider } from "react-redux";
import appStatus from "./infrastructure/AppReducers";

import { PrimeReactProvider } from "primereact/api";
import "primereact/resources/themes/md-light-indigo/theme.css"; // theme
import "primereact/resources/primereact.min.css"; // core css
import "primeicons/primeicons.css"; //Prime icons

import { Skeleton } from "primereact/skeleton";
import AppHeader from "./toolbars/AppHeader";
import CookieConsent from "react-cookie-consent";
import AppStatusBar from "./AppStatusBar";
import RequireAuth from "./infrastructure/RequireAuth";

import HomeShell from "./HomeShell";
import BingoShell from "./BingoBoards/BingoShell";
import AssignmentShell from "./assignments/AssignmentShell";
import Welcome from "./info/Welcome";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import DiversityCheck from "./DiversityCheck";

const ProfileDataAdmin = React.lazy(() => import("./profile/ProfileDataAdmin"));
const InstallmentReport = React.lazy(() =>
  import("./checkin/InstallmentReport")
);
const Experience = React.lazy(() => import("./experiences/Experience"));
const ConsentLog = React.lazy(() => import("./Consent/ConsentLog"));
const Admin = React.lazy(() => import("./Admin"));
const ReportingAdmin = React.lazy(() => import("./Reports/ReportingAdmin"));
const EnrollInCourse = React.lazy(() => import("./EnrollInCourse"));

const Privacy = React.lazy(() => import("./info/Privacy"));
const TermsOfService = React.lazy(() => import("./info/TermsOfService"));
const AppInit = React.lazy(() => import("./infrastructure/AppInit"));
const PasswordEdit = React.lazy(() => import("./PasswordEdit"));
const Demo = React.lazy(() => import("./Demo"));

type Props = {
  getEndpointsUrl: string;
  debug?: boolean;
};

export default function PageWrapper(props: Readonly<Props>) {
  const store = appStatus;

  const router = createBrowserRouter(
    createRoutesFromElements(
        <Route
          element={
            <Suspense fallback={<Skeleton className="mb-2" height={"50rem"} />}>
              <AppHeader />
              <WorkingIndicator />
              <br />
              <AppStatusBar />
              <Outlet />
            </Suspense>
          }
        >
          <Route
            element={
              <div className="mainContent">
                <Outlet />
              </div>
            }
          >
            <Route index element={<Navigate to={"welcome"} replace={true} />} />
            <Route path={"welcome/*"} element={<Welcome />} />
            <Route
              path={"login"}
              element={<Navigate to={"/welcome/login"} replace={true} />}
            />
            <Route
              path="profile"
              element={
                <Suspense fallback={<Skeleton className="mb-2" />}>
                  <RequireAuth>
                    <ProfileDataAdmin />
                  </RequireAuth>
                </Suspense>
              }
            />
            <Route
              path="admin/*"
              element={
                <Suspense fallback={<Skeleton className={"mb-2"} />}>
                  <RequireAuth>
                    <Admin />
                  </RequireAuth>
                </Suspense>
              }
            />
          <Route path={"reporting"} element={<ReportingAdmin />} />
            <Route
              path={"home/*"}
              element={
                <Suspense fallback={<Skeleton className={"mb-2"} />}>
                  <RequireAuth>
                    <Outlet />
                  </RequireAuth>
                </Suspense>
              }
            >
              <Route index element={<HomeShell />} />
              <Route
                path={`login`}
                element={<Navigate to={"/home"} relative={"path"} />}
              />
              <Route
                path={`project/checkin/:installmentId`}
                element={<InstallmentReport />}
              />
              <Route
                path="bingo/*"
                element={<BingoShell />} />
              {/* Perhaps subgroup under Experience */}
              <Route
                path={`experience/:experienceId`}
                element={<Experience />}
              />
              {/* Perhaps subgroup under Assignment */}
              <Route
                path={`assignment/*`}
                element={<AssignmentShell />} />
              <Route
                path={`research_information/:consentFormId`}
                element={<ConsentLog />}
              />
              <Route
                path={`course/:courseId/enroll`}
                element={<EnrollInCourse />}
              />
            </Route>

            <Route path="user/password/edit" element={<PasswordEdit />} />
            <Route path={`tos`} element={<TermsOfService />} />
            <Route path={`privacy`} element={<Privacy />} />
            <Route
              path={`perspective`}
              element={
                <Suspense fallback={<Skeleton className={"mb-2"} />}>
                  <RequireAuth>
                    <DiversityCheck />
                  </RequireAuth>
                </Suspense>
              }
            />
            <Route
              path="demo/*"
              element={
                <Suspense fallback={<Skeleton className={""} />}>
                  <Demo rootPath="demo" />
                </Suspense>
              }
            />
          </Route>
        </Route>
    ), {
      future: {
        v7_relativeSplatPath: true,
        v7_startTransition: true
      },
    }
  );

  return (
    <Provider store={store}>
      <PrimeReactProvider>
        <AppInit endpointsUrl={props.getEndpointsUrl} debug={props.debug}>
          <CookieConsent>
            This website uses cookies to enhance the user experience.
          </CookieConsent>
          <RouterProvider router={router} />
        </AppInit>
      </PrimeReactProvider>
    </Provider>
  );
}
