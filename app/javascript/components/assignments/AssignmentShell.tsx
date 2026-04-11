import React, { Suspense, useState } from "react";
import { Route, Routes } from "react-router";
import WorkingIndicator from "../infrastructure/WorkingIndicator";
import RequireInstructor from "../infrastructure/RequireInstructor";
import { Skeleton } from "primereact/skeleton";

const AssignmentViewer = React.lazy(() => import("./AssignmentViewer"));
const CritiqueShell = React.lazy(() => import("./CritiqueShell"));

type Props = {
  rootPath?: string;
};

export default function AssignmentShell( props: Props) {
  const [working] = useState(true);

  return (
    <React.Fragment>
      <WorkingIndicator identifier="assignments" />
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <Routes>
        <Route
          path={`:assignmentId`}
          element={<AssignmentViewer rootPath={props.rootPath} />}
        />
        <Route
          path={`critiques/:assignmentId`}
          element={
            <RequireInstructor>
              <CritiqueShell rootPath={props.rootPath} />
            </RequireInstructor>
          }
        />
        </Routes>
      </Suspense>
    </React.Fragment>
  );
}
