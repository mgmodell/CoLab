import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import PropTypes from "prop-types";
import Paper from "@mui/material/Paper";
import Grid from "@mui/material/Grid";
import Tab from "@mui/material/Tab";
import {
  TabList,
  TabContext,
  TabPanel
} from "@mui/lab";
import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";
import luxonPlugin from "@fullcalendar/luxon";
import { DateTime, Settings } from "luxon";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusActions";

import DecisionEnrollmentsTable from "./DecisionEnrollmentsTable";
import DecisionInvitationsTable from "./DecisionInvitationsTable";
import ConsentLog from "./Consent/ConsentLog";
import ProfileDataAdmin from "./ProfileDataAdmin";
import { useTranslation } from "react-i18next";
import TaskList from "./TaskList";
import Skeleton from "@mui/material/Skeleton";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { Box } from "@mui/material";

export default function HomeShell(props) {
  const category = "home";
  //const endpoints = useTypedSelector(state=>state['context'].endpoints[endpointSet])
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const dispatch = useDispatch();
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();

  const [curTab, setCurTab] = useState("list");

  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(state => state.context.lookups.timezone_lookup);
  const [tasks, setTasks] = useState();

  useEffect(() => {
    if (null !== user.lastRetrieved && null !== tz_hash ) {
      const userZone = tz_hash[ user.timezone ];
      Settings.defaultZoneName = tz_hash[ userZone ] ;
      console.log( 'in the zone:', userZone, tasks );
      if( undefined !== tasks ){
        const newTasks = tasks;
        newTasks.forEach( (value, index, array ) =>{
          value.next_date = value.next_date.setZone( userZone )
          value.start_date = value.start_date.setZone( userZone )
        })

        setTasks( newTasks );
      }
    }
  }, [user.lastRetrieved, tz_hash, tasks]);

  //Initialising to null
  const [consentLogs, setConsentLogs] = useState();
  const [waitingRosters, setWaitingRosters] = useState();

  const getTasks = () => {
    const url = props.rootPath !== undefined ?
      `${props.rootPath}${endpoints.taskListUrl}.json` :
      `${endpoints.taskListUrl}.json`;

    dispatch(startTask());
    axios.get(url, {}).then(resp => {
      //Process the data
      const data = resp.data;
      console.log( 'tasks:', data['tasks'] );
      data["tasks"].forEach((value, index, array) => {
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
        if( props.rootPath === undefined ){
          value.url = value.link
        } else {
          const url = `/${props.rootPath}${value.link}`;
          value.url = url;
          value.link = url;
        }
        // Set the dates properly - close may need work
        value.start = value.next_date;
        if( null !== value.next_date ){
          value.next_date = DateTime.fromISO( value.next_date );
        }
        if( null !== value.start_date ){
          value.start_date = DateTime.fromISO( value.start_date );
        }
      });
      setTasks(data.tasks);
      setConsentLogs(data.consent_logs);
      setWaitingRosters(data.waiting_rosters);

      dispatch(endTask());
    });
  };

  useEffect(() => {
    if (props.rootPath !== undefined || ( endpointsLoaded && isLoggedIn) ) {
      getTasks();
    }
  }, [endpointsLoaded, isLoggedIn]);

  const handleTabChange = (event, newValue ) =>{
    setCurTab( newValue );
  }

  var pageContent = <Skeleton variant="rectangular" />;
  if (undefined !== consentLogs) {
    if (consentLogs.length > 0) {
      pageContent = (
        <ConsentLog
          consentFormId={consentLogs[0].consent_form_id}
          parentUpdateFunc={getTasks}
        />
      );
    } else if (isLoggedIn && !user.welcomed) {
      pageContent = <ProfileDataAdmin profileId={user.id} />;
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
          <TabContext value={curTab} >
            <Box >
              <TabList onChange={(event,newValue) =>
                setCurTab( newValue )
              } >
                <Tab label="Task View" value="list" />
                <Tab label="Calendar View" value="calendar" />
              </TabList>
            </Box>

          <TabPanel value='calendar' >
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
                navigate(info.event.url);
              }}
              plugins={[dayGridPlugin, luxonPlugin]}
            />

          </TabPanel>
          <TabPanel value="list">
            <TaskList tasks={tasks} />
          </TabPanel>
          </TabContext>
        </React.Fragment>
      );
    }
  }

  return (
    <Paper>
      <Grid container spacing={3}>
        {endpointsLoaded ? (
          <React.Fragment>
            <Grid item xs={12}>
              {undefined !== waitingRosters && waitingRosters.length > 0 ? (
                <DecisionInvitationsTable
                  invitations={waitingRosters}
                  parentUpdateFunc={getTasks}
                />
              ) : null}
            </Grid>
            <Grid item xs={12}>
              {undefined !== endpoints["courseRegRequestsUrl"] &&
              undefined !== endpoints["courseRegUpdatesUrl"] ? (
                <DecisionEnrollmentsTable
                  init_url={endpoints["courseRegRequestsUrl"]}
                  update_url={endpoints["courseRegUpdatesUrl"]}
                />
              ) : null}
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
  rootPath: PropTypes.string
};
