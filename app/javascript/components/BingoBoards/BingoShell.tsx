import React, { useState, useEffect } from "react";
import { Route, Routes, Navigate } from "react-router-dom";
import WorkingIndicator from "../infrastructure/WorkingIndicator";

import CandidateListEntry from "./CandidateListEntry";
import CandidatesReviewTable from "./CandidatesReviewTable";
import BingoBuilder from "./BingoBuilder";
import ScoreBingoWorksheet from "./ScoreBingoWorksheet";
import RequireInstructor from "../infrastructure/RequireInstructor";

export default function BingoShell(props) {

  const [showErrors, setShowErrors] = useState(false);

  const [working] = useState(true);

  return (
    <React.Fragment>
      <WorkingIndicator id="admin_save" />
      <Routes>
                  <Route
                    path={`enter_candidates/:bingoGameId`}
                    element={
                        <CandidateListEntry />
                    }
                  />
                  <Route
                    path={`review_candidates/:bingoGameId`}
                    element={
                      <RequireInstructor>
                        <CandidatesReviewTable />
                      </RequireInstructor>
                    }
                  />
                  <Route
                    path={`candidate_results/:bingoGameId`}
                    element={
                        <BingoBuilder />
                    }
                  />
                  <Route
                    path={`score_bingo_worksheet/:worksheetIdParam`}
                    element={
                      <RequireInstructor>
                        <ScoreBingoWorksheet />
                      </RequireInstructor>
                    }
                  />
      </Routes>
    </React.Fragment>
  );
}

BingoShell.propTypes = {};
