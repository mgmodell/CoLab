import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Alert from "@material-ui/lab/Alert";
import IconButton from "@material-ui/core/IconButton";
import Tooltip from "@material-ui/core/Tooltip";
import Settings from "luxon/src/settings.js";

import AddIcon from '@material-ui/icons/Add'
import CloseIcon from '@material-ui/icons/Close'

import { useEndpointStore } from"./infrastructure/EndPointStore";
import { useStatusStore } from './infrastructure/StatusStore';
import { useUserStore } from "./infrastructure/UserStore";
import MUIDataTable from "mui-datatables";
import Collapse from "@material-ui/core/Collapse";

export default function SchoolList(props) {
  const endpointSet = "school";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const [status, statusActions] = useStatusStore( );
  const columns = [
    {
      label: "Name",
      name: "name",
      options: {
        filter: false,
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
  ]

  const [schools, setSchools] = useState([]);

  const getSchools = () => {
    const url = endpoints.endpoints[endpointSet].baseUrl + ".json";

    statusActions.startTask( );
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
        setSchools(data);
        statusActions.endTask( 'loading' );
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      statusActions.startTask( );
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      getSchools();
      statusActions.endTask( 'loading' );
    }
  }, [endpoints.endpointStatus[endpointSet]]);

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
                window.location.href =
                  endpoints.endpoints[endpointSet].schoolCreateUrl;
              }}
              aria-label="New School"
            >
              <AddIcon />
            </IconButton>
          </Tooltip>
        ),
        onCellClick: (colData, cellMeta) => {
          if ("Actions" != columns[cellMeta.colIndex].label) {
            const link =
              endpoints.endpoints[endpointSet].baseUrl +
              "/" +
              schools[cellMeta.dataIndex].id;
            if (null != link) {
              window.location.href = link;
            }
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
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
