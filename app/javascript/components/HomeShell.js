import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import Paper from "@material-ui/core/Paper";
import { DateTime } from "luxon";
import Settings from "luxon/src/settings.js";
import Tab from "@material-ui/core/Tab";
import Tabs from "@material-ui/core/Tabs";
import FullCalendar from '@fullcalendar/react'
import dayGridPlugin from '@fullcalendar/daygrid'
import luxonPlugin from '@fullcalendar/luxon'

import { useEndpointStore } from "./EndPointStore";
import { useUserStore } from "./UserStore";
import DecisionEnrollmentsTable from './DecisionEnrollmentsTable';
import { i18n } from './i18n';
import {useTranslation} from 'react-i18next';
import TaskList from './TaskList'

export default function HomeShell(props) {
  const endpointSet = "home";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();
  const { t, i18n } = useTranslation( );

  const [working, setWorking] = useState(true);

  const [curTab, setCurTab] = useState( 'calendar' )

  const [tasks, setTasks] = useState([]);

  const getTasks = () => {
    var url = endpoints.endpoints[endpointSet].taskListUrl + ".json";

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
        data.forEach((value,index,array)=>{
          switch( value.type ){
            case 'assessment':
              value.title = 
                value.group_name + ' for ('  + value.name + ')'
              break;
            case 'bingo_game':
              value.title = value.name;
              break;
            case 'experience':
              value.title = value.name;
              break;
          }
          value.url = value.link;
          value.start = value.next_date;
        })
        setTasks(data);
        setWorking(false);
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
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

  return (
    <Paper>
      {'loaded' === endpoints.endpointStatus[endpointSet] ?
      (
        <DecisionEnrollmentsTable
          token={props.token}
          init_url={endpoints.endpoints[endpointSet].courseRegRequestsUrl}
          update_url={endpoints.endpoints[endpointSet].courseRegUpdatesUrl}
          />
      )
      : null }
        <h1>{t( 'home.your_tasks' )}</h1>
        <p>{t( 'home.greeting', { name: user.first_name } )},<br/>
        {t( 'home.task_interval', { postProcess: 'interval', count: tasks.length} )}
        </p>
        <Tabs value={curTab} onChange={(event,newValue)=>{setCurTab(newValue)}}>
          <Tab label='Calendar View' value='calendar'/>
          <Tab label='Task View' value='list'/>
        </Tabs>
      {working ? <LinearProgress id='waiting' /> : null}
      {( 'calendar' === curTab ) ?
        (<FullCalendar
            headerToolbar={{
              center: 'thisWeek,dayGridMonth'

            }}
            initialView="thisWeek"
            views={{
              thisWeek:{
                type: 'dayGrid',
                duration: {
                  weeks: 2
                },
                buttonText: 'Two Weeks'
              },
              dayGridMonth:{
                buttonText: 'One Month'
              }
            }}
            displayEventTime={false}
            events={tasks}
            plugins={[ dayGridPlugin, luxonPlugin ]}
          />) : null
      }
      {( 'list' === curTab ) ?
        (
          <TaskList tasks={tasks}/>
        ) : null
      }
    </Paper>
  );
}

HomeShell.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
