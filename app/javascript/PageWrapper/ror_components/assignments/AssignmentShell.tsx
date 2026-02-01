import React, { useState } from "react";
import { Route, Routes } from "react-router";
import WorkingIndicator from "../infrastructure/WorkingIndicator";

import RequireInstructor from "../infrastructure/RequireInstructor";
import AssignmentViewer from "./AssignmentViewer";
import CritiqueShell from "./CritiqueShell";

type Props = {
  rootPath?: string;
};

export default function AssignmentShell( props: Props) {
  const [working] = useState(true);

  return (
    <React.Fragment>
      <WorkingIndicator identifier="assignments" />
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
    </React.Fragment>
  );
}
