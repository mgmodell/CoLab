import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import {
  useRouteMatch,
  useHistory
} from "react-router-dom";
import Alert from "@material-ui/lab/Alert";
import IconButton from "@material-ui/core/IconButton";
import Tooltip from "@material-ui/core/Tooltip";
import Settings from "luxon/src/settings.js";

import AddIcon from "@material-ui/icons/Add";
import CloseIcon from "@material-ui/icons/Close";

import {useDispatch} from 'react-redux';
import {startTask, endTask} from './infrastructure/StatusActions';

import MUIDataTable from "mui-datatables";
import Collapse from "@material-ui/core/Collapse";
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function SchoolList(props) {
  const endpointSet = "school";
  const endpoints = useTypedSelector(state=>state['context'].endpoints[endpointSet])
  const endpointStatus = useTypedSelector(state=>state['context'].endpointsLoaded)
  const user = useTypedSelector(state=>state['login'].profile)
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  let { path, url } = useRouteMatch();
  const history = useHistory( );

  const dispatch = useDispatch( );
  const columns = [
    {
      label: "Name",
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: "Courses",
      name: "courses",
      options: {
        filter: false,
        display: true
      }
    },
    {
      label: "Students",
      name: "students",
      options: {
        filter: false,
        display: true
      }
    },
    {
      label: "Instructors",
      name: "instructors",
      options: {
        filter: false,
        display: false
      }
    },
    {
      label: "Projects",
      name: "projects",
      options: {
        filter: false,
        display: false
      }
    },
    {
      label: "Experiences",
      name: "experiences",
      options: {
        filter: false,
        display: false
      }
    },
    {
      label: "Terms Lists",
      name: "terms_lists",
      options: {
        filter: false,
        display: false
      }
    }
  ];

  const [schools, setSchools] = useState([]);

  const getSchools = () => {
    const url = endpoints.baseUrl + ".json";

    dispatch( startTask() );
    fetch(url, {
      method: "GET",
      credentials: "include",
      cache: "no-cache",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
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
        setSchools(data);
        dispatch( endTask("loading") );
      });
  };

  useEffect(() => {
    if (endpointStatus ){
      getSchools();
      dispatch( endTask("loading") );
    }
  }, [endpointStatus]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  const postNewMessage = msgs => {
    setMessages(msgs);
    setShowErrors(true);
  };

  const muiDatTab = (
    <MUIDataTable
      title="Schools"
      data={schools}
      columns={columns}
      options={{
        responsive: "standard",
        filter: false,
        print: false,
        download: false,
        customToolbar: () => (
          <Tooltip title="New School">
            <IconButton
              id="new_school"
              onClick={event => {
                history.push( path + '/new' );
                //window.location.href =
                //  endpoints.endpoints[endpointSet].schoolCreateUrl;
              }}
              aria-label="New School"
            >
              <AddIcon />
            </IconButton>
          </Tooltip>
        ),
        onCellClick: (colData, cellMeta) => {
          if ("Actions" != columns[cellMeta.colIndex].label) {
            const id = schools[cellMeta.dataIndex].id;
            history.push( `${path}/${id}` )
          }
        },
        selectableRows: "none"
      }}
    />
  );

  return (
    <React.Fragment>
      <Collapse in={showErrors}>
        <Alert
          action={
            <IconButton
              aria-label="close"
              color="inherit"
              size="small"
              onClick={() => {
                setShowErrors(false);
              }}
            >
              <CloseIcon fontSize="inherit" />
            </IconButton>
          }
        >
          {messages["main"] || null}
        </Alert>
      </Collapse>
      <div style={{ maxWidth: "100%" }}>{muiDatTab}</div>
    </React.Fragment>
  );
}

SchoolList.propTypes = {
};
