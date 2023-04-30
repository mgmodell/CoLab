import React, { useState, useEffect, Suspense } from "react";
import axios from "axios";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";
import PropTypes from "prop-types";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import Paper from "@mui/material/Paper";
import Tooltip from "@mui/material/Tooltip";
import { DateTime, Settings } from "luxon";

import CloudDownloadIcon from "@mui/icons-material/CloudDownload";
import BookIcon from "@mui/icons-material/Book";
import AddIcon from "@mui/icons-material/Add";
import CloseIcon from "@mui/icons-material/Close";

import CopyActivityButton from "./CopyActivityButton";
import MUIDataTable from "mui-datatables";
import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { startTask, endTask } from "./infrastructure/StatusSlice";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import { Skeleton } from "@mui/material";

export default function CourseList(props) {
  const endpointSet = "course";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  // Settings.throwOnInvalid = true;

  const navigate = useNavigate();

  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  function PaperComponent(props) {
    return <Paper {...props} />;
  }

  const dispatch = useDispatch();
  const columns = [
    {
      label: "Number",
      name: "number",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          return (
            <span>
              <BookIcon />
              &nbsp;{value}
            </span>
          );
        }
      }
    },
    {
      label: "Name",
      name: "name",
      options: {
        filter: false,
        display: true
      }
    },
    {
      label: "School",
      name: "school_name",
      options: {
        filter: true,
        display: true
      }
    },
    {
      label: "Open Date",
      name: "start_date",
      options: {
        filter: false,
        display: true,
        customBodyRender: (value, tableMeta, updateValue) => {
          const dt = DateTime.fromISO(value);
          return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
        }
      }
    },
    {
      label: "Close Date",
      name: "end_date",
      options: {
        filter: false,
        display: true,
        customBodyRender: (value, tableMeta, updateValue) => {
          const dt = DateTime.fromISO(value);
          return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
        }
      }
    },
    {
      label: "Faculty",
      name: "faculty_count",
      options: {
        filter: false,
        display: false
      }
    },
    {
      label: "Students",
      name: "student_count",
      options: {
        filter: false,
        display: false
      }
    },
    {
      label: "Projects",
      name: "project_count",
      options: {
        filter: false,
        display: false
      }
    },
    {
      label: "Experiences",
      name: "experience_count",
      options: {
        filter: false,
        display: false
      }
    },
    {
      label: "Bingo Games",
      name: "bingo_game_count",
      options: {
        filter: false,
        display: false
      }
    },
    {
      label: "Actions",
      name: "id",
      options: {
        display: true,
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const course = courses.filter(item => {
            return value == item.id;
          })[0];
          const scoresUrl = endpoints.scoresUrl + value + ".csv";
          const copyUrl = endpoints.courseCopyUrl + value + ".json";
          return (
            <React.Fragment>
              <Tooltip title="Download Scores to CSV">
                <IconButton
                  id={"csv-" + value}
                  onClick={event => {
                    window.location.href = scoresUrl;
                    event.preventDefault();
                  }}
                  aria-label="Download scores as CSV"
                  size="large"
                >
                  <CloudDownloadIcon />
                </IconButton>
              </Tooltip>
              <CopyActivityButton
                copyUrl={endpoints.courseCopyUrl}
                itemId={value}
                itemUpdateFunc={getCourses}
                startDate={new Date(course["start_date"])}
                addMessagesFunc={postNewMessage}
              />
            </React.Fragment>
          );
        }
      }
    }
  ];

  const [courses, setCourses] = useState([]);
  const [newStartDate, setNewStartDate] = useState(DateTime.local());

  const getCourses = () => {
    const url = endpoints.baseUrl + ".json";
    dispatch(startTask("loading"));

    axios
      .get(url, {})
      .then(response => {
        //Process the data
        setCourses(response.data);
        dispatch(endTask("loading"));
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      dispatch(endTask("loading"));
      getCourses();
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
      title="Available Courses"
      data={courses}
      columns={columns}
      options={{
        responsive: "standard",
        filterType: "checkbox",
        print: false,
        download: false,
        customToolbar: () => (
          <Tooltip title="New Course">
            <IconButton
              id="new_course"
              onClick={event => {
                navigate("new");
              }}
              aria-label="New Course"
              size="large"
            >
              <AddIcon />
            </IconButton>
          </Tooltip>
        ),
        onCellClick: (colData, cellMeta) => {
          if ("Actions" != columns[cellMeta.colIndex].label) {
            const course_id = courses[cellMeta.dataIndex].id;
            const location = String(course_id);
            navigate(location);
          }
        },
        selectableRows: "none"
      }}
    />
  );

  return (
      <Suspense fallback={<Skeleton variant={'rectangular'} />} >

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
      <WorkingIndicator identifier="courses_loading" />
      {null !== user.lastRetrieved ? (
        <div style={{ maxWidth: "100%" }}>{muiDatTab}</div>
      ) : null}
      </Suspense>
  );
}

CourseList.propTypes = {};
