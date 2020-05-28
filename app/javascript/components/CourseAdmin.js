import React, { useEffect } from "react";
import {
  Route,
  Switch,
  useRouteMatch} from 'react-router-dom';
import PropTypes from "prop-types";
import Settings from "luxon/src/settings.js";

import CourseList from './CourseList';
import CourseDataAdmin from './CourseDataAdmin';
import BingoGameDataAdmin from './BingoBoards/BingoGameDataAdmin';
import ExperienceDataAdmin from './ExperienceDataAdmin';
import ProjectDataAdmin from './ProjectDataAdmin';

import { useUserStore } from "./infrastructure/UserStore";

export default function CourseAdmin(props) {
  let match = useRouteMatch();

  const [user] = useUserStore();

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  return (
      <Switch>
        <Route path={`${match.path}/:course_id/bingo_game/:id`}
          render={routeProps => (
            <React.Fragment>
              <BingoGameDataAdmin
                token={props.token}
                getEndpointsUrl={props.getEndpointsUrl}
                courseId={routeProps.match.params.course_id}
                bingoGameId={'new' === routeProps.match.params.id ?
                  null :
                  routeProps.match.params.id
                }
                />

            </React.Fragment>
          )}
        />
        <Route path={`${match.path}/:course_id/experience/:id`}
          render={routeProps => (
            <React.Fragment>
              <ExperienceDataAdmin
                token={props.token}
                getEndpointsUrl={props.getEndpointsUrl}
                courseId={routeProps.match.params.course_id}
                experienceId={'new' === routeProps.match.params.id ?
                  null :
                  Number( routeProps.match.params.id )
                }
                />

            </React.Fragment>
          )}
        />
        <Route path={`${match.path}/:course_id/project/:id`}
          render={routeProps => (
            <React.Fragment>
              <ProjectDataAdmin
                token={props.token}
                getEndpointsUrl={props.getEndpointsUrl}
                courseId={routeProps.match.params.course_id}
                projectId={'new' === routeProps.match.params.id ?
                  null :
                  Number( routeProps.match.params.id )
                }
                />

            </React.Fragment>
          )}
        />
        <Route path={`${match.path}/:course_id`}
          render={routeProps => (
            <React.Fragment>
              <CourseDataAdmin
                token={props.token}
                getEndpointsUrl={props.getEndpointsUrl}
                courseId={'new' === routeProps.match.params.course_id ?
                  null :
                  Number( routeProps.match.params.course_id )
                }
                />

            </React.Fragment>
          )}
        />
        <Route exact path={`${match.path}`}>
          <CourseList
            token={props.token}
            getEndpointsUrl={props.getEndpointsUrl}
            />

        </Route>
      </Switch>
  );
}

CourseAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
