import React, { useState } from "react";
import { Route, Routes } from "react-router-dom";
import WorkingIndicator from "../infrastructure/WorkingIndicator";
import ProfileDataAdmin from "./ProfileDataAdmin";
import AssignmentViewer from "../assignments/AssignmentViewer";
import BingoBuilder from "../BingoBoards/BingoBuilder";

type Props = {
  rootPath?: string;
};

export default function ProfileShell(props: Props) {
  const [working] = useState(true);

  return (
    <React.Fragment>
      <WorkingIndicator identifier="play_bingo" />
      <Routes>
        <Route index element={<ProfileDataAdmin />} />
        <Route
          path={`bingo_game/:bingoGameId`}
          element={<BingoBuilder rootPath={props.rootPath} />}
        />
        <Route
          path={`assignment/:assignmentId`}
          element={<AssignmentViewer />}
        />
      </Routes>
    </React.Fragment>
  );
}
