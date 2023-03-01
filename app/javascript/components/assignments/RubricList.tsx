import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import Tooltip from "@mui/material/Tooltip";
import { Settings } from "luxon";

import AddIcon from "@mui/icons-material/Add";
import CloseIcon from "@mui/icons-material/Close";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import {DataGrid, GridColDef} from '@mui/x-data-grid';
import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";
import AdminListToolbar from "../infrastructure/AdminListToolbar";

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
    { field: 'id', hide: true },
    { field: 'name', headerName: t( 'name' ) },
    { field: 'published', headerName: t( 'show.published') },
    { field: 'version', type: 'number',  headerName: t( 'version' ) },
    { field: 'user', headerName: t( 'show.creator') }
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
        <div style={{ display: 'flex', height: '100%'}} >
          <div style={ { flexGrow: 1 }} >
          <DataGrid
            autoHeight
            rows={rubrics}
            columns={columns}
            isCellEditable={(params)=>{
              return false;
            }}
            onCellClick={ ( params, event, details )=>{
              navigate(String(params.row.id));
              /*
              const id = schools[cellMeta.dataIndex].id;
              navigate(String(id));
              */

            } }
            components={{
              Toolbar: AdminListToolbar
            }}
          />

        </div>
      </div>
    </React.Fragment>
  );
}

RubricList.propTypes = {};
