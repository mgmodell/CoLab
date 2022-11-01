import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import Tooltip from "@mui/material/Tooltip";
import { Settings } from "luxon";

import AddIcon from "@mui/icons-material/Add";
import CloseIcon from "@mui/icons-material/Close";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusSlice";

import MUIDataTable from "mui-datatables";
import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "./infrastructure/AppReducers";
import axios from "axios";

export default function SchoolList(props) {
  const endpointSet = "school";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const navigate = useNavigate();

  const dispatch = useDispatch();
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

    dispatch(startTask());
    axios.get(url, {}).then(response => {
      //Process the data
      setSchools(response.data);
      dispatch(endTask("loading"));
    });
  };

  useEffect(() => {
    if (endpointStatus) {
      getSchools();
      dispatch(endTask("loading"));
    }
  }, [endpointStatus]);

  useEffect(() => {
    if (null !== user.lastRetrieved && null !== tz_hash) {
      Settings.defaultZoneName = tz_hash[user.timezone];
    }
  }, [user.lastRetrieved, tz_hash]);

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
                navigate("new");
                //window.location.href =
                //  endpoints.endpoints[endpointSet].schoolCreateUrl;
              }}
              aria-label="New School"
              size="large"
            >
              <AddIcon />
            </IconButton>
          </Tooltip>
        ),
        onCellClick: (colData, cellMeta) => {
          if ("Actions" != columns[cellMeta.colIndex].label) {
            const id = schools[cellMeta.dataIndex].id;
            navigate(String(id));
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

SchoolList.propTypes = {};
