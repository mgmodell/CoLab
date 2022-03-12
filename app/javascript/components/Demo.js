import React, { useEffect, useState, Suspense } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  useParams } from "react-router-dom";
import { Provider } from "react-redux";
import { createStore, applyMiddleware, compose } from "redux";
import thunk from "redux-thunk";
import appStatus from "./infrastructure/AppReducers";

import Skeleton from "@mui/material/Skeleton";
import {
  ThemeProvider,
  StyledEngineProvider,
  createTheme,
} from "@mui/material";
import PropTypes from "prop-types";
import AppHeader from "./AppHeader";

import HomeShell from "./HomeShell";
import ProfileDataAdmin from "./ProfileDataAdmin";
import InstallmentReport from "./InstallmentReport";
import CandidateListEntry from "./BingoBoards/CandidateListEntry";
import CandidatesReviewTable from "./BingoBoards/CandidatesReviewTable";
import BingoBuilder from "./BingoBoards/BingoBuilder";
import Experience from "./Experience";
import ConsentLog from "./Consent/ConsentLog";
import Admin from "./Admin";
import AppStatusBar from "./AppStatusBar";
import SignIn from "./SignIn";
import EnrollInCourse from "./EnrollInCourse";
import ScoreBingoWorksheet from "./BingoBoards/ScoreBingoWorksheet";
import Privacy from "./Privacy";
import TermsOfService from "./TermsOfService";
import AppInit from "./infrastructure/AppInit";
import PasswordEdit from './PasswordEdit';


export default function Demo(props) {


  return (

                <Routes>
                  <Route
                    path={`submit_installment/:installmentId`}
                    element={
                        <InstallmentReport
                          rootPath={`${props.rootPath}/api-backend` }
                        />
                    }
                  />
                  {/* Perhaps subgroup under Bingo */}
                  <Route
                    path={`enter_candidates/:bingoGameId`}
                    element={
                        <CandidateListEntry
                          rootPath={props.rootPath}
                        />
                    }
                  />
                  <Route
                    path={`review_candidates/:bingoGameId`}
                    element={
                        <CandidatesReviewTable
                          rootPath={props.rootPath }
                        />
                    }
                  />
                  <Route
                    path={`candidate_results/:bingoGameId`}
                    element={
                        <BingoBuilder
                          rootPath={props.rootPath}
                        />
                    }
                  />
                  {/* Perhaps subgroup under Bingo */}
                  <Route
                    path={`experience/:experienceId`}
                    element={
                        <Experience
                          rootPath={`${props.rootPath}/api-backend` }
                        />
                    }
                  />
                  <Route
                    path="/"
                    element={
                        <HomeShell 
                          rootPath="demo"
                        />
                    }
                  />
                </Routes>
  );
}

Demo.propTypes = {
  rootPath: PropTypes.string.isRequired
};
