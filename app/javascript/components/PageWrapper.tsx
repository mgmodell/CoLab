import React, { Suspense } from "react";
import {
  createBrowserRouter,
  RouterProvider,
  BrowserRouter as Router,
  Route,
  createRoutesFromElements,
  Outlet,
  Navigate,
  useLocation
} from "react-router-dom";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";
import appStatus from "./infrastructure/AppReducers";

import { PrimeReactProvider, PrimeReactContext } from "primereact/api";
import "primereact/resources/themes/md-light-indigo/theme.css"; // theme
import "primereact/resources/primereact.min.css"; // core css
import "primeicons/primeicons.css"; //Prime icons

import Skeleton from "@mui/material/Skeleton";
import {
  ThemeProvider,
  StyledEngineProvider,
  createTheme
} from "@mui/material";
import PropTypes from "prop-types";
import AppHeader from "./AppHeader";
import CookieConsent from "react-cookie-consent";
import AppStatusBar from "./AppStatusBar";
import RequireAuth from "./infrastructure/RequireAuth";

import HomeShell from "./HomeShell";
import BingoShell from "./BingoBoards/BingoShell";
import AssignmentShell from "./assignments/AssignmentShell";
import Welcome from "./info/Welcome";

const ProfileDataAdmin = React.lazy(() => import("./profile/ProfileDataAdmin"));
const InstallmentReport = React.lazy(() => import("./InstallmentReport"));
const Experience = React.lazy(() => import("./experiences/Experience"));
const ConsentLog = React.lazy(() => import("./Consent/ConsentLog"));
const Admin = React.lazy(() => import("./Admin"));
const SignIn = React.lazy(() => import("./SignIn"));
const EnrollInCourse = React.lazy(() => import("./EnrollInCourse"));

const Privacy = React.lazy(() => import("./info/Privacy"));
const TermsOfService = React.lazy(() => import("./info/TermsOfService"));
const WhatIsIt = React.lazy(() => import("./info/WhatIsIt"));
const AppInit = React.lazy(() => import("./infrastructure/AppInit"));
const PasswordEdit = React.lazy( () => import( './PasswordEdit'))
const Demo = React.lazy(() => import("./Demo"));

type Props = {
  getEndpointsUrl: string
}

export default function PageWrapper(props : Props) {
  const store = configureStore({
    reducer: appStatus
  });

  const styles = createTheme({
  });

  console.log( 'wrapping again' );

  const router = createBrowserRouter(
    createRoutesFromElements(
      <React.Fragment>
        <Route
          element={
            <Suspense fallback={<Skeleton variant="rectangular" height={50} />}>
              <AppHeader />
              <br />
              <AppStatusBar />
              <Outlet />
            </Suspense>
          }
        >
          <Route element={<Outlet />}>
            <Route
              index
              element={
                <Navigate to={'welcome'} replace={true} />
              }
            />
            <Route
              path={'welcome/*'}
              element={
                <Welcome />
              }
            />
            <Route
              path={'login'}
              element={
                <Navigate
                  to={'/welcome/login'}
                  replace={true}
                />
              }
            />
            <Route
              path="profile"
              element={
                <Suspense fallback={<Skeleton variant={"rectangular"} />}>
                  <RequireAuth>
                    <ProfileDataAdmin />
                  </RequireAuth>
                </Suspense>
              }
            />
            <Route
              path="admin/*"
              element={
                <Suspense fallback={<Skeleton variant={"rectangular"} />}>
                  <RequireAuth>
                    <Admin />
                  </RequireAuth>
                </Suspense>
              }
            />
            <Route
              path={'home/*'}
              element={
                <Suspense fallback={<Skeleton variant={"rectangular"} />}>
                  <RequireAuth>
                    <Outlet />
                  </RequireAuth>
                </Suspense>
              }
            >
              <Route
                index
                element={
                  <HomeShell />
                }
              />
              <Route
                path={`submit_installment/:installmentId`}
                element={
                  <InstallmentReport />
                }
              />
              {/* Perhaps subgroup under Bingo */}
              <Route
                path="bingo/*"
                element={
                  <BingoShell />
                }
              />
              {/* Perhaps subgroup under Experience */}
              <Route
                path={`experience/:experienceId`}
                element={
                  <Experience />
                }
              />
              {/* Perhaps subgroup under Assignment */}
              <Route
                path={`assignment/*`}
                element={
                  <AssignmentShell />
                }
              />
              <Route
                path={`research_information/:consentFormId`}
                element={
                  <ConsentLog />
                }
              />
              <Route
                path={`course/:courseId/enroll`}
                element={
                  <RequireAuth>
                    <EnrollInCourse />
                  </RequireAuth>
                }
              />
            </Route>

            <Route path="user/password/edit" element={<PasswordEdit />} />
            <Route path={`what_is_colab`} element={<WhatIsIt />} />
            <Route path={`tos`} element={<TermsOfService />} />
            <Route path={`privacy`} element={<Privacy />} />
            <Route
              path="demo/*"
              element={
                <Suspense fallback={<Skeleton variant={"rectangular"} />}>
                  <Demo rootPath="demo" />
                </Suspense>
              }
            />
          </Route>
        </Route>
      </React.Fragment>
    )
  );

  return (
    <Provider store={store}>
      <PrimeReactProvider>
        <StyledEngineProvider injectFirst>
          <ThemeProvider theme={styles}>
            <AppInit endpointsUrl={props.getEndpointsUrl}>
              <CookieConsent>
                This website uses cookies to enhance the user experience.
              </CookieConsent>
              <RouterProvider router={router} />
            </AppInit>
          </ThemeProvider>
        </StyledEngineProvider>
      </PrimeReactProvider>
    </Provider>
  );
}

