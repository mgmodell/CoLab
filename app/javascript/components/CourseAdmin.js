import React, { useEffect } from "react";
import { Route, Routes } from "react-router-dom";
import PropTypes from "prop-types";
import { Settings } from "luxon";

const CourseList = React.lazy(() => import("./CourseList"));
const CourseDataAdmin = React.lazy(() => import("./CourseDataAdmin"));
const BingoGameDataAdmin = React.lazy(() =>
  import("./BingoBoards/BingoGameDataAdmin")
);
const ExperienceDataAdmin = React.lazy(() => import("./ExperienceDataAdmin"));
const ProjectDataAdmin = React.lazy(() => import("./ProjectDataAdmin"));
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function CourseAdmin(props) {
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );

  useEffect(() => {
    if (null !== user.lastRetrieved && null !== tz_hash) {
      Settings.defaultZoneName = tz_hash[user.timezone];
    }
  }, [user.lastRetrieved, tz_hash]);

  return (
    <Routes>
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
      <Route path={`:courseIdParam`} element={<CourseDataAdmin />} />
      <Route exact path={`/`} element={<CourseList />} />
    </Routes>
  );
}

CourseAdmin.propTypes = {};
