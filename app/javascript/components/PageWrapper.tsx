import React, { Suspense } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";
import appStatus from "./infrastructure/AppReducers";

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

const ProfileDataAdmin = React.lazy(() => import("./ProfileDataAdmin"));
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
const PasswordEdit = React.lazy(() => import("./PasswordEdit"));
const Demo = React.lazy(() => import("./Demo"));

export default function PageWrapper(props) {
  const store = configureStore({
    reducer: appStatus
  });

  const styles = createTheme({
    typography: {
      useNextVariants: true
    }
  });

  return (
    <Provider store={store}>
      <StyledEngineProvider injectFirst>
        <ThemeProvider theme={styles}>
          <AppInit endpointsUrl={props.getEndpointsUrl}>
            <CookieConsent>
              This website uses cookies to enhance the user experience.
            </CookieConsent>
            <Router>
              <Suspense
                fallback={<Skeleton variant="rectangular" height={50} />}
              >
                <AppHeader />
              </Suspense>
              <br />
              <AppStatusBar />

              <Suspense
                fallback={<Skeleton variant="rectangular" height={600} />}
              >
                <Routes>
                  <Route
                    path="profile"
                    element={
                      <RequireAuth>
                        <ProfileDataAdmin />
                      </RequireAuth>
                    }
                  />
                  <Route
                    path="admin/*"
                    element={
                      <RequireAuth>
                        <Admin />
                      </RequireAuth>
                    }
                  />
                  <Route
                    path={`submit_installment/:installmentId`}
                    element={
                      <RequireAuth>
                        <InstallmentReport />
                      </RequireAuth>
                    }
                  />
                  {/* Perhaps subgroup under Bingo */}
                  <Route
                    path='bingo/*'
                    element={
                      <RequireAuth>
                        <BingoShell />
                      </RequireAuth>
                    }
                    />
                  {/* Perhaps subgroup under Experience */}
                  <Route
                    path={`experience/:experienceId`}
                    element={
                      <RequireAuth>
                        <Experience />
                      </RequireAuth>
                    }
                  />
                  <Route
                    path={`research_information/:consentFormId`}
                    element={
                      <RequireAuth>
                        <ConsentLog />
                      </RequireAuth>
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
                  <Route path="user/password/edit" element={<PasswordEdit />} />
                  <Route path={`what_is_colab`} element={<WhatIsIt />} />
                  <Route path={`tos`} element={<TermsOfService />} />
                  <Route path={`privacy`} element={<Privacy />} />
                  <Route
                    path="/"
                    element={
                      <RequireAuth>
                        <HomeShell />
                      </RequireAuth>
                    }
                  />
                  <Route path="demo/*" element={<Demo rootPath="demo" />} />
                  <Route path="login" element={<SignIn />} />
                </Routes>
              </Suspense>
            </Router>
          </AppInit>
        </ThemeProvider>
      </StyledEngineProvider>
    </Provider>
  );
}

PageWrapper.propTypes = {
  getEndpointsUrl: PropTypes.string.isRequired
};
