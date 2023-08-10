import React, { useState } from "react";
import { Route, Routes } from "react-router-dom";
import WorkingIndicator from "../infrastructure/WorkingIndicator";


import RequireInstructor from "../infrastructure/RequireInstructor";
import AssignmentViewer from "./AssignmentViewer";
import CritiqueShell from "./CritiqueShell";

export default function AssignmentShell() {
  const [working] = useState(true);

  return (
    <React.Fragment>
      <WorkingIndicator identifier="play_bingo" />
      <Routes>
        <Route
          path={`:assignmentId`}
          element={<AssignmentViewer />}
        />
        <Route
          path={`:assignmentId/:submissionId`}
          element={<div>nothing yet</div>}
        />
        <Route
          path={`critiques/:assignmentId`}
          element={
            <RequireInstructor>
              <CritiqueShell />
            </RequireInstructor>
          }
        />
      </Routes>
    </React.Fragment>
  );
}

AssignmentShell.propTypes = {};
