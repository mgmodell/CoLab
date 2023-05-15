import React, { useEffect } from "react";
import { Outlet, Route, Routes } from "react-router-dom";
import PropTypes from "prop-types";
import { Settings } from "luxon";

const CourseList = React.lazy(() => import("./CourseList"));
const CourseDataAdmin = React.lazy(() => import("./CourseDataAdmin"));
const BingoGameDataAdmin = React.lazy(() =>
  import("./BingoBoards/BingoGameDataAdmin")
);
const ExperienceDataAdmin = React.lazy(() =>
  import("./experiences/ExperienceDataAdmin")
);
const ProjectDataAdmin = React.lazy(() => import("./ProjectDataAdmin"));
const AssignmentDataAdmin = React.lazy(() =>
  import("./assignments/AssignmentDataAdmin")
);
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function CourseAdmin(props) {
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );

  return (
    <Routes>
      <Route path="/" element={<Outlet/>} >
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
        <Route path={`:courseIdParam`} element={<CourseDataAdmin />} />
        <Route
          index
          element={<CourseList />} />

      </Route>
    </Routes>
  );
}

CourseAdmin.propTypes = {};
