import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";

import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";

import CloseIcon from "@mui/icons-material/Close";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";
import { DataGrid, GridCellParams, GridColDef } from "@mui/x-data-grid";
import AdminListToolbar from "../infrastructure/AdminListToolbar";
import { renderTextCellExpand } from "../infrastructure/GridCellExpand";

export default function SchoolList(props) {
  const category = "school";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { t } = useTranslation(`${category}s`);

  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const navigate = useNavigate();

  const dispatch = useDispatch();
  const columns: GridColDef[] = [
    {
      headerName: t("index.name_lbl"),
      field: "name",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("index.courses_lbl"),
      field: "courses",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("index.students_lbl"),
      field: "students"
    },
    {
      headerName: t("index.instructors_lbl"),
      field: "instructors"
    },
    {
      headerName: t("index.project_lbl"),
      field: "projects"
    },
    {
      headerName: t("index.experience_lbl"),
      field: "experiences"
    },
    {
      headerName: t("index.terms_list_lbl"),
      field: "terms_lists"
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

  const postNewMessage = msgs => {
    setMessages(msgs);
    setShowErrors(true);
  };

  const schoolTable = (
    <DataGrid
      isCellEditable={() => false}
      columns={columns}
      rows={schools}
      slots={{
        toolbar: AdminListToolbar
      }}
      slotProps={{
        toolbar: {
          itemType: category
        }
      }}
      onCellClick={(params: GridCellParams) => {
        navigate(String(params.row.id));
      }}
      pageSizeOptions={[5, 10, 100]}
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
      <div style={{ maxWidth: "100%" }}>{schoolTable}</div>
    </React.Fragment>
  );
}
