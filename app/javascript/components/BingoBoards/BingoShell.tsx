import React, { Suspense, useState } from "react";
import { Route, Routes } from "react-router";
import WorkingIndicator from "../infrastructure/WorkingIndicator";
import RequireInstructor from "../infrastructure/RequireInstructor";
import { Skeleton } from "primereact/skeleton";

const CandidateListEntry = React.lazy(() => import("./CandidateListEntry"));
const CandidatesReviewTable = React.lazy(() => import("./CandidatesReviewTable"));
const BingoBuilder = React.lazy(() => import("./BingoBuilder"));
const ScoreBingoWorksheet = React.lazy(() => import("./ScoreBingoWorksheet"));

type Props = {
  rootPath?: string;
};
export default function BingoShell(props: Props) {
  const [working] = useState(true);

  return (
    <React.Fragment>
      <WorkingIndicator identifier="play_bingo" />
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <Routes>
        <Route
          path={`enter_candidates/:bingoGameId`}
          element={<CandidateListEntry rootPath={props.rootPath} />}
        />
        <Route
          path={`review_candidates/:bingoGameId`}
          element={
            <>
              {undefined === props.rootPath ? (
                <RequireInstructor>
                  <CandidatesReviewTable rootPath={props.rootPath} />
                </RequireInstructor>
              ) : (
                <CandidatesReviewTable rootPath={props.rootPath} />
              )}
            </>
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
      </Suspense>
    </React.Fragment>
  );
}
