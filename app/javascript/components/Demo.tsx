import React, { useEffect, useState, Suspense } from "react";
import { Routes, Route, Outlet, Navigate } from "react-router-dom";

import HomeShell from "./HomeShell";
import { Skeleton } from "primereact/skeleton";

const InstallmentReport = React.lazy(() => import("./InstallmentReport"));

import BingoShell from "./BingoBoards/BingoShell";
const Experience = React.lazy(() => import("./experiences/Experience"));

type Props = {
  rootPath: string
}
export default function Demo(props: Props) {
  return (
    <Routes>
      <Route
        path={'home'}
        element={
          <Suspense fallback={<Skeleton height={'10rem'} className={'mb-2'} />}>
            <Outlet />
          </Suspense>
        }
      >

        <Route
          path={`submit_installment/:installmentId`}
          element={
            <InstallmentReport rootPath={props.rootPath} />
          }
        />
        {/* Perhaps subgroup under Bingo */}
        <Route
          path="bingo/*"
          element={
            <BingoShell />
          }
        />

        {/* Perhaps subgroup under Bingo */}
        <Route
          path={`experience/:experienceId`}
          element={<Experience rootPath={`${props.rootPath}/api-backend`} />}
        />
        <Route index element={<HomeShell rootPath={'demo'} />} />
      </Route>
      <Route
        index
        element={
          <Navigate to={'home'} />
        }
        />
    </Routes>
  );
}
