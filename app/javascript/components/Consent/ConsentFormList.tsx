import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";

import CloseIcon from "@mui/icons-material/Close";
import CheckIcon from "@mui/icons-material/Check";

import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useTranslation } from "react-i18next";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import AdminListToolbar from "../infrastructure/AdminListToolbar";
import { renderTextCellExpand } from "../infrastructure/GridCellExpand";

export default function ConsentFormList(props) {
  const category = "consent_form";
  const { t } = useTranslation( `${category}s`);
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const dispatch = useDispatch();

  const navigate = useNavigate();

  const user = useTypedSelector(state => state.profile.user);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const columns: GridColDef[] = [
    {
      headerName: t('index.name_col' ),
      field: "name",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t('index.active_col'),
      field: "active",
      renderCell: (params) => {
        const output = params.value ? <CheckIcon /> : null;
        return output;

      }
    }
  ];

  const [consent_forms, setSchools] = useState([]);

  const getSchools = () => {
    const url = endpoints.baseUrl + ".json";
    dispatch(startTask("loading"));

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //Process the data
        setSchools(data);
        dispatch(endTask("loading"));
      })
      .catch(error => {
        console.log("error", error);
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

  const dataTable = (
    <DataGrid
      isCellEditable={()=>false}
      columns={columns}
      rows={consent_forms}
      slots={{
        toolbar: AdminListToolbar
      }}
      slotProps={{
        toolbar:{
          itemType: category

        }
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
      <div style={{ maxWidth: "100%" }}>{dataTable}</div>
    </React.Fragment>
  );
}
