import React, { Suspense, useState, useEffect } from "react";
import { Route, Routes } from "react-router";
import { useTranslation } from "react-i18next";
import WorkingIndicator from "../infrastructure/WorkingIndicator";
import RequireInstructor from "../infrastructure/RequireInstructor";
import { Skeleton } from "primereact/skeleton";
import { useTour } from "../infrastructure/TourContext";

import CandidatesReviewTable from "./CandidatesReviewTable";
import CandidateListEntry from "./CandidateListEntry";
import BingoBuilder from "./BingoBuilder";
import ScoreBingoWorksheet from "./ScoreBingoWorksheet";

type Props = {
  rootPath?: string;
};
export default function BingoShell(props: Props) {
  const { t } = useTranslation("bingo_games");
  const [working] = useState(true);
  const { setTourSteps } = useTour();

  useEffect(() => {
    setTourSteps([
      {
        element: "body",
        popover: {
          title: t("no_help_title"),
          description: t("no_help_description"),
          align: "center",
          side: "left"
        }
      }
    ]);
    return () => setTourSteps([]);
  }, [setTourSteps]);

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
