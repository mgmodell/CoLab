import React, { useEffect } from "react";
import { Route, Switch, useRouteMatch } from "react-router-dom";
import PropTypes from "prop-types";
import Settings from "luxon/src/settings.js";

import CourseList from "./CourseList";
import CourseDataAdmin from "./CourseDataAdmin";
import BingoGameDataAdmin from "./BingoBoards/BingoGameDataAdmin";
import ExperienceDataAdmin from "./ExperienceDataAdmin";
import ProjectDataAdmin from "./ProjectDataAdmin";
import { useTypedSelector } from "./infrastructure/AppReducers";


export default function CourseAdmin(props) {
  let match = useRouteMatch();

  const user = useTypedSelector(state=>state.profile.user)

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  return (
    <Switch>
      <Route
        path={`${match.path}/:course_id/bingo_game/:id`}
        render={routeProps => (
          <React.Fragment>
            <BingoGameDataAdmin
              courseId={Number( routeProps.match.params.course_id )}
              bingoGameId={
                "new" === routeProps.match.params.id
                  ? null
                  : Number( routeProps.match.params.id )
              }
            />
          </React.Fragment>
        )}
      />
      <Route
        path={`${match.path}/:course_id/experience/:id`}
        render={routeProps =>{
        return (
          <React.Fragment>
            <ExperienceDataAdmin
              courseId={Number( routeProps.match.params.course_id )}
              experienceId={
                "new" === routeProps.match.params.id
                  ? null
                  : Number(routeProps.match.params.id)
              }
            />
          </React.Fragment>
        )


        }
      } />
      <Route
        path={`${match.path}/:course_id/project/:id`}
        render={routeProps => (
          <React.Fragment>
            <ProjectDataAdmin
              courseId={Number( routeProps.match.params.course_id )}
              projectId={
                "new" === routeProps.match.params.id
                  ? null
                  : Number(routeProps.match.params.id)
              }
            />
          </React.Fragment>
        )}
      />
      <Route
        path={`${match.path}/:course_id`}
        render={routeProps => (
          <React.Fragment>
            <CourseDataAdmin
              courseId={
                "new" === routeProps.match.params.course_id
                  ? null
                  : Number(routeProps.match.params.course_id)
              }
            />
          </React.Fragment>
        )}
      />
      <Route exact path={`${match.path}`}>
        <CourseList
        />
      </Route>
    </Switch>
  );
}

CourseAdmin.propTypes = {
};
