import React, { useState, useEffect, Suspense } from "react";
import axios from "axios";
import { useDispatch } from "react-redux";
import { useLocation, useNavigate } from "react-router-dom";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import Tooltip from "@mui/material/Tooltip";
import { DateTime } from "luxon";

import CloudDownloadIcon from "@mui/icons-material/CloudDownload";
import BookIcon from "@mui/icons-material/Book";
import CloseIcon from "@mui/icons-material/Close";

import CopyActivityButton from "./CopyActivityButton";
import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import WorkingIndicator from "../infrastructure/WorkingIndicator";
import { Skeleton } from "@mui/material";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";
import { renderDateCellExpand, renderTextCellExpand } from "../infrastructure/GridCellExpand";
import AdminListToolbar from "../infrastructure/AdminListToolbar";

export default function CourseList(props) {
  const category = "course";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  // Settings.throwOnInvalid = true;

  const navigate = useNavigate();
  const location = useLocation( );
  const {t} = useTranslation( `${category}s`);

  const user = useTypedSelector(state => state.profile.user);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const dispatch = useDispatch();
  const columns: GridColDef[] = [
    {
      headerName: t( 'index.number_col'),
      field: "number",
      renderCell: (params) => {
          return (
            <span>
              <BookIcon />
              &nbsp;{params.value}
            </span>
          );
      }
    },
    {
      headerName: t( 'index.name_col'),
      field: "name",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t( 'index.school_col'),
      field: "school_name",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t( 'index.open_col'),
      field: "start_date",
      renderCell: renderDateCellExpand
    },
    {
      headerName: t( 'index.close_col'),
      field: "end_date",
      renderCell: renderDateCellExpand
    },
    {
      headerName: t( 'index.faculty_col'),
      field: "faculty_count",
    },
    {
      headerName: t( 'index.students_col'),
      field: "student_count",
    },
    {
      headerName: t( 'index.projects_col'),
      field: "project_count",
    },
    {
      headerName: t( 'index.experiences_col'),
      field: "experience_count",
    },
    {
      headerName: t( 'index.bingo_games_col'),
      field: "bingo_game_count",
    },
    {
      headerName: t( 'index.actions_col'),
      field: "id",
      renderCell: (params) => {
        const course = params.row;
        const scoresUrl = endpoints.scoresUrl + params.value + ".csv";
        const copyUrl = endpoints.courseCopyUrl + params.value + ".json";
        return (
          <React.Fragment>
            <Tooltip title="Download Scores to CSV">
              <IconButton
                id={"csv-" + params.value}
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
              itemId={params.value}
              itemUpdateFunc={getCourses}
              startDate={new Date(course["start_date"])}
              addMessagesFunc={postNewMessage}
            />
          </React.Fragment>
        );

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

  const postNewMessage = msgs => {
    setMessages(msgs);
    setShowErrors(true);
  };

  const dataTable = (
    <DataGrid
    columns={columns}
    rows={courses}
    slots={{
      toolbar: AdminListToolbar
    }}
    slotProps={{
      toolbar: {
        itemType: category
      }
    }}
    onCellClick={(params)=>{
      if ('id' != params.colDef.field) {
        const course_id = params.row.id
        //This ought not be necessary and I would like to ask about it on SO - 
        //when time permits
        const locaLocation = `${location.pathname}/${String(course_id)}`;
        navigate(locaLocation, {relative: false });
      }

    }}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 5 }
          }
        }}
        pageSizeOptions={[5, 10]}

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
        <div style={{ maxWidth: "100%" }}>{dataTable}</div>
      ) : null}
      </Suspense>
  );
}

CourseList.propTypes = {};
