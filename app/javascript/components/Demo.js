import React, { useEffect, useState, Suspense } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route } from "react-router-dom";
import PropTypes from "prop-types";

import HomeShell from "./HomeShell";
import InstallmentReport from "./InstallmentReport";
import CandidateListEntry from "./BingoBoards/CandidateListEntry";
import CandidatesReviewTable from "./BingoBoards/CandidatesReviewTable";
import BingoBuilder from "./BingoBoards/BingoBuilder";
import Experience from "./Experience";


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
