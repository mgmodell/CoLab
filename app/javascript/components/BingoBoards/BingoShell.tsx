import React, { useState } from "react";
import { Route, Routes } from "react-router-dom";
import WorkingIndicator from "../infrastructure/WorkingIndicator";

import CandidateListEntry from "./CandidateListEntry";
import CandidatesReviewTable from "./CandidatesReviewTable";
import BingoBuilder from "./BingoBuilder";
import ScoreBingoWorksheet from "./ScoreBingoWorksheet";
import RequireInstructor from "../infrastructure/RequireInstructor";


type Props = {
  rootPath?: string

}
export default function BingoShell( props: Props) {
  const [working] = useState(true);

  return (
    <React.Fragment>
      <WorkingIndicator identifier="play_bingo" />
      <Routes>
        <Route
          path={`enter_candidates/:bingoGameId`}
          element={<CandidateListEntry rootPath={props.rootPath}/>}
        />
        <Route
          path={`review_candidates/:bingoGameId`}
          element={
            <RequireInstructor>
              <CandidatesReviewTable rootPath={props.rootPath} />
            </RequireInstructor>
          }
        />
        <Route
          path={`candidate_results/:bingoGameId`}
          element={<BingoBuilder rootPath={props.rootPath} />}
        />
        <Route
          path={`score_bingo_worksheet/:worksheetIdParam`}
          element={
            <RequireInstructor>
              {/* No rootPath because there exists no demo for it */}
              <ScoreBingoWorksheet />
            </RequireInstructor>
          }
        />
      </Routes>
    </React.Fragment>
  );
}