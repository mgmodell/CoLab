import React, { useState, useEffect } from "react";
import {
  useHistory,
  useRouteMatch
} from 'react-router-dom';
import PropTypes from "prop-types";
import Alert from "@material-ui/lab/Alert";
import IconButton from "@material-ui/core/IconButton";
import Paper from "@material-ui/core/Paper";
import Tooltip from "@material-ui/core/Tooltip";
import { DateTime } from "luxon";
import Settings from "luxon/src/settings.js";

import CloudDownloadIcon from "@material-ui/icons/CloudDownload";
import BookIcon from "@material-ui/icons/Book";
import AddIcon from "@material-ui/icons/Add";
import CloseIcon from "@material-ui/icons/Close";

import { useEndpointStore } from "./infrastructure/EndPointStore";
import { useUserStore } from "./infrastructure/UserStore";
import { useStatusStore } from './infrastructure/StatusStore';
import CopyActivityButton from "./CopyActivityButton";
import MUIDataTable from "mui-datatables";
import Collapse from "@material-ui/core/Collapse";
import WorkingIndicator from './infrastructure/WorkingIndicator';

export default function CourseList(props) {
  const endpointSet = "course";
  const [endpoints, endpointsActions] = useEndpointStore();

  const history = useHistory( );
  const {path, url} = useRouteMatch( );

  const [user, userActions] = useUserStore();
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  function PaperComponent(props) {
    return <Paper {...props} />;
  }

  const [status, statusActions] = useStatusStore( );
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
          const dt = DateTime.fromISO(value, {
            zone: Settings.defaultZoneName
          });
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
          const dt = DateTime.fromISO(value, {
            zone: Settings.defaultZoneName
          });
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
          const course = courses.filter((item)=>{
            return value == item.id;
          })
          const scoresUrl =
            endpoints.endpoints[endpointSet].scoresUrl + value + ".csv";
          const copyUrl =
            endpoints.endpoints[endpointSet].courseCopyUrl + value + ".json";
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
                >
                  <CloudDownloadIcon />
                </IconButton>
              </Tooltip>
              <CopyActivityButton
                token={props.token}
                copyUrl={endpoints.endpoints[endpointSet].courseCopyUrl}
                itemId={value}
                itemUpdateFunc={getCourses}
                startDate={new Date(course['start_date'])}
                addMessagesFunc={postNewMessage}
              />
            </React.Fragment>
          );
        }
      }
    }
  ];

  const [courses, setCourses] = useState([]);
  const [newStartDate, setNewStartDate] = useState(DateTime.local().toISO());

  const getCourses = () => {
    const url = endpoints.endpoints[endpointSet].baseUrl + ".json";

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
        setCourses(data);
        statusActions.setWorking(false);
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      statusActions.setWorking( true )
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      getCourses();
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
      title="Courses"
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
                history.push(
                  path + '/new'
                )
              }}
              aria-label="New Course"
            >
              <AddIcon />
            </IconButton>
          </Tooltip>
        ),
        onCellClick: (colData, cellMeta) => {
          if ("Actions" != columns[cellMeta.colIndex].label) {
            console.log( path )
              const course_id = courses[cellMeta.dataIndex].id
              console.log(  course_id );
              const location = path + '/' + course_id
              console.log( location ) 
              history.push(
                location
              )
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
      <WorkingIndicator identifier='courses_loading' />
      <div style={{ maxWidth: "100%" }}>{muiDatTab}</div>
    </React.Fragment>
  );
}

CourseList.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
