import React from "react";
import { Outlet, Route, Routes } from "react-router";

import CourseList from "./CourseList";
import CourseDataAdmin from "./CourseDataAdmin";
import BingoGameDataAdmin from "../BingoBoards/BingoGameDataAdmin";
import ExperienceDataAdmin from "../experiences/ExperienceDataAdmin";
import ProjectDataAdmin from "../projects/ProjectDataAdmin";
import AssignmentDataAdmin from "../assignments/AssignmentDataAdmin";

import { useTypedSelector } from "../infrastructure/AppReducers";

export default function CourseAdmin(props) {
  const user = useTypedSelector(state => state.profile.user);

  return (
    <Routes>
      <Route path="/" element={<Outlet />}>
        <Route
          path={`:courseIdParam/bingo_game/:bingoGameIdParam`}
          element={<BingoGameDataAdmin />}
        />
        <Route
          path={`:courseIdParam/experience/:experienceIdParam`}
          element={<ExperienceDataAdmin />}
        />
        <Route
          path={`:courseIdParam/project/:projectIdParam`}
          element={<ProjectDataAdmin />}
        />
        <Route
          path={`:courseIdParam/assignment/:assignmentIdParam`}
          element={<AssignmentDataAdmin />}
        />
        <Route path={`:courseIdParam/*`} element={<CourseDataAdmin />} />
        <Route index element={<CourseList />} />
      </Route>
    </Routes>
  );
}
