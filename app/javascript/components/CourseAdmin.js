import React, { useEffect } from "react";
import { Route, Routes } from "react-router-dom";
import PropTypes from "prop-types";
import Settings from "luxon/src/settings.js";

import CourseList from "./CourseList";
import CourseDataAdmin from "./CourseDataAdmin";
import BingoGameDataAdmin from "./BingoBoards/BingoGameDataAdmin";
import ExperienceDataAdmin from "./ExperienceDataAdmin";
import ProjectDataAdmin from "./ProjectDataAdmin";
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function CourseAdmin(props) {
  const user = useTypedSelector(state => state.profile.user);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

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
