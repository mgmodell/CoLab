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

import LocalLibraryIcon from "@material-ui/icons/LocalLibrary";
import GridOffIcon from "@material-ui/icons/GridOff";
import TuneIcon from "@material-ui/icons/Tune";

import { useEndpointStore } from "./EndPointStore";
import { useUserStore } from "./UserStore";
import TaskList from './TaskList'

export default function HomeShell(props) {
  const endpointSet = "home";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();

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
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
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
