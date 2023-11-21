import React, { useEffect, useState, Suspense } from "react";
import { Routes, Route, Outlet } from "react-router-dom";

import HomeShell from "./HomeShell";
import { Skeleton } from "@mui/material";
const InstallmentReport = React.lazy(() => import("./InstallmentReport"));
const CandidateListEntry = React.lazy(() =>
  import("./BingoBoards/CandidateListEntry")
);
const CandidatesReviewTable = React.lazy(() =>
  import("./BingoBoards/CandidatesReviewTable")
);
const BingoBuilder = React.lazy(() => import("./BingoBoards/BingoBuilder"));
const Experience = React.lazy(() => import("./experiences/Experience"));

type Props = {
  rootPath: string
}
export default function Demo(props : Props) {
  return (
    <Routes>
      <Route
        element={<Outlet />}
        >

      <Route
        path={`submit_installment/:installmentId`}
        element={
          <InstallmentReport rootPath={props.rootPath} />
        }
      />
      {/* Perhaps subgroup under Bingo */}
      <Route
        path={`bingo/enter_candidates/:bingoGameId`}
        element={<CandidateListEntry rootPath={props.rootPath} />}
      />
      <Route
        path={`bingo/review_candidates/:bingoGameId`}
        element={<CandidatesReviewTable rootPath={props.rootPath} />}
      />
      <Route
        path={`bingo/candidate_results/:bingoGameId`}
        element={<BingoBuilder rootPath={props.rootPath} />}
      />
      {/* Perhaps subgroup under Bingo */}
      <Route
        path={`experience/:experienceId`}
        element={<Experience rootPath={`${props.rootPath}/api-backend`} />}
      />
      <Route index element={<HomeShell rootPath="demo" />} />
        </Route>
    </Routes>
  );
}
