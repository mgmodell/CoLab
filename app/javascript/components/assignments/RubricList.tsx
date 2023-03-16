import React, { Fragment, useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import Tooltip from "@mui/material/Tooltip";
import { Settings } from "luxon";

import AddIcon from "@mui/icons-material/Add";
import CloseIcon from "@mui/icons-material/Close";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import { DataGrid, GridRowModel, GridColDef } from "@mui/x-data-grid";
import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";
import AdminListToolbar from "../infrastructure/AdminListToolbar";

import FileCopyIcon from "@mui/icons-material/FileCopy";
import DeleteIcon from "@mui/icons-material/Delete";

import axios from "axios";

export default function RubricList(props) {
  const category = "rubric";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );
  const { t } = useTranslation(`${category}s`);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const navigate = useNavigate();

  const dispatch = useDispatch();
  const columns: GridColDef[] = [
    { field: "name", headerName: t("name") },
    { field: "published", headerName: t("show.published") },
    {
      field: "version",
      type: "number",
      headerName: t("version"),
      getApplyQuickFilterFn: undefined
    },
    { field: "user", headerName: t("show.creator") },
    {
      field: "actions",
      headerName: "",
      type: "actions",
      editable: false,
      sortable: false,
      renderCell: (params: GridRenderCellParams) => (
        <Fragment>
          <Tooltip title={t("rubric.copy")}>
            <IconButton
              id="copy_rubric"
              onClick={event => {
                const rubric = Object.assign(
                  {},
                  rubrics.find(value => {
                    return params.id == value.id;
                  })
                );
                const url = `${endpoints["baseUrl"]}/copy/${rubric.id}.json`;
                axios
                  .get(url)
                  .then(resp => {
                    console.log("resp", resp);
                    // check for possible errors
                    getRubrics();
                  })
                  .catch(error => {
                    console.log(error);
                  });
              }}
              aria-label={t("rubric.copy")}
              size="small"
            >
              <FileCopyIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title={t("rubric.delete")}>
            <IconButton
              id="delete_rubric"
              aria-label={t("rubric.delete")}
              disabled={params.row.published}
              onClick={event => {
                const rubric = Object.assign(
                  {},
                  rubrics.find(value => {
                    return params.id == value.id;
                  })
                );
                const url = `${endpoints["baseUrl"]}/${rubric.id}.json`;
                axios.delete(url).then(resp => {
                  // check for possible errors
                  getRubrics();
                });
              }}
              size="small"
            >
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        </Fragment>
      )
    }
  ];

  const [rubrics, setRubrics] = useState([]);

  const getRubrics = () => {
    const url = endpoints.baseUrl + ".json";

    dispatch(startTask());
    axios.get(url, {}).then(response => {
      //Process the data
      setRubrics(response.data);
      dispatch(endTask("loading"));
    });
  };

  useEffect(() => {
    if (endpointStatus) {
      getRubrics();
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
      <div style={{ display: "flex", height: "100%" }}>
        <div style={{ flexGrow: 1 }}>
          <DataGrid
            getRowId={(model: GridRowModel) => {
              return model.id;
            }}
            autoHeight
            rows={rubrics}
            columns={columns}
            isCellEditable={params => {
              return false;
            }}
            onCellClick={(params, event, details) => {
              if ("actions" != params.field) {
                navigate(String(params.row.id));
              }
            }}
            components={{
              Toolbar: AdminListToolbar
            }}
            componentsProps={{
              toolbar: {
                activityType: "rubric"
              }
            }}
          />
        </div>
      </div>
    </React.Fragment>
  );
}

RubricList.propTypes = {};
