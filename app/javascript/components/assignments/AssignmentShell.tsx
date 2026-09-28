import React, { Suspense, useState, useEffect } from "react";
import { Route, Routes } from "react-router";
import WorkingIndicator from "../infrastructure/WorkingIndicator";
import RequireInstructor from "../infrastructure/RequireInstructor";
import { Skeleton } from "primereact/skeleton";
import { useTour } from "../infrastructure/TourContext";

import AssignmentViewer from "./AssignmentViewer";
import CritiqueShell from "./CritiqueShell";

type Props = {
  rootPath?: string;
};

export default function AssignmentShell( props: Props) {
  const [working] = useState(true);
  const { setTourSteps } = useTour();

  useEffect(() => {
    setTourSteps([
      {
        element: "body",
        popover: {
          title: "Assignments",
          description: "Review assignment details, submit your responses, and check progress feedback in this section.",
          align: "center",
          side: "left"
        }
      }
    ]);
    return () => setTourSteps([]);
  }, [setTourSteps]);

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
