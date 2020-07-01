import React, { useState, useEffect } from "react";
import { useHistory } from "react-router-dom";
import PropTypes from "prop-types";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Paper from "@material-ui/core/Paper";
import Grid from "@material-ui/core/Grid";
import { DateTime } from "luxon";
import Settings from "luxon/src/settings.js";
import Tab from "@material-ui/core/Tab";
import Tabs from "@material-ui/core/Tabs";
import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import luxonPlugin from "@fullcalendar/luxon";

import { useEndpointStore } from "./infrastructure/EndPointStore";
import { useUserStore } from "./infrastructure/UserStore";
import { useStatusStore } from "./infrastructure/StatusStore";

import DecisionEnrollmentsTable from "./DecisionEnrollmentsTable";
import DecisionInvitationsTable from "./DecisionInvitationsTable";
import ConsentLog from "./Consent/ConsentLog";
import ProfileDataAdmin from "./ProfileDataAdmin";
import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";
import TaskList from "./TaskList";
import Skeleton from "@material-ui/lab/Skeleton";

export default function HomeShell(props) {
  const endpointSet = "home";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();
  const [status, statusActions] = useStatusStore();
  const { t, i18n } = useTranslation();
  const history = useHistory();

  const [curTab, setCurTab] = useState("list");

  //Initialising to null
  const [tasks, setTasks] = useState();
  const [consentLogs, setConsentLogs] = useState();
  const [waitingRosters, setWaitingRosters] = useState();

  const getTasks = () => {
    var url = endpoints.endpoints[endpointSet].taskListUrl + ".json";

    statusActions.startTask();
    fetch(url, {
      method: "GET",
      credentials: "include",
      cache: "no-cache",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        //Process the data
        data.tasks.forEach((value, index, array) => {
          switch (value.type) {
            case "assessment":
              value.title = value.group_name + " for (" + value.name + ")";
              break;
            case "bingo_game":
              value.title = value.name;
              break;
            case "experience":
              value.title = value.name;
              break;
          }
          value.url = value.link;
          value.start = value.next_date;
        });
        setTasks(data.tasks);
        setConsentLogs(data.consent_logs);
        setWaitingRosters(data.waiting_rosters);

        statusActions.endTask();
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] !== "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] === "loaded") {
      getTasks();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  var pageContent = <Skeleton variant="rect" />;
  if (undefined !== consentLogs) {
    if (consentLogs.length > 0) {
      pageContent = (
        <ConsentLog
          token={props.token}
          getEndpointsUrl={props.getEndpointsUrl}
          consentFormId={consentLogs[0].consent_form_id}
          parentUpdateFunc={getTasks}
        />
      );
    } else if (user.loaded && !user.welcomed) {
      pageContent = (
        <ProfileDataAdmin
          token={props.token}
          getEndpointsUrl={props.getEndpointsUrl}
          profileId={user.id}
        />
      );
    } else {
      pageContent = (
        <React.Fragment>
          <h1>{t("home.your_tasks")}</h1>
          <p>
            {t("home.greeting", { name: user.first_name })},<br />
            {t("home.task_interval", {
              postProcess: "interval",
              count: tasks.length
            })}
          </p>
          <Tabs
            value={curTab}
            onChange={(event, newValue) => {
              setCurTab(newValue);
            }}
          >
            <Tab label="Task View" value="list" />
            <Tab label="Calendar View" value="calendar" />
          </Tabs>
          {"calendar" === curTab ? (
            <FullCalendar
              headerToolbar={{
                center: "thisWeek,dayGridMonth"
              }}
              initialView="thisWeek"
              views={{
                thisWeek: {
                  type: "dayGrid",
                  duration: {
                    weeks: 2
                  },
                  buttonText: "Two Weeks"
                },
                dayGridMonth: {
                  buttonText: "One Month"
                }
              }}
              displayEventTime={false}
              events={tasks}
              eventClick={info => {
                history.push(info.event.url);
              }}
              plugins={[dayGridPlugin, luxonPlugin]}
            />
          ) : null}
          {"list" === curTab ? <TaskList tasks={tasks} /> : null}
        </React.Fragment>
      );
    }
  }

  return (
    <Paper>
      <Grid container spacing={3}>
        {"loaded" === endpoints.endpointStatus[endpointSet] ? (
          <React.Fragment>
            <Grid item xs={12}>
              {undefined !== waitingRosters && waitingRosters.length > 0 ? (
                <DecisionInvitationsTable
                  token={props.token}
                  invitations={waitingRosters}
                  parentUpdateFunc={getTasks}
                />
              ) : null}
            </Grid>
            <Grid item xs={12}>
              <DecisionEnrollmentsTable
                token={props.token}
                init_url={endpoints.endpoints[endpointSet].courseRegRequestsUrl}
                update_url={
                  endpoints.endpoints[endpointSet].courseRegUpdatesUrl
                }
              />
            </Grid>
          </React.Fragment>
        ) : null}
        <Grid item xs={12}>
          {pageContent}
        </Grid>
      </Grid>
    </Paper>
  );
}

HomeShell.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
