import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import Alert from "@mui/material/Alert";
import IconButton from "@mui/material/IconButton";
import Tooltip from "@mui/material/Tooltip";

import AddIcon from "@mui/icons-material/Add";
import CloseIcon from "@mui/icons-material/Close";
import CheckIcon from "@mui/icons-material/Check";

import MUIDataTable from "mui-datatables";
import Collapse from "@mui/material/Collapse";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

export default function ConsentFormList(props) {
  const endpointSet = "consent_form";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const dispatch = useDispatch();

  const navigate = useNavigate();

  const user = useTypedSelector(state => state.profile.user);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const columns = [
    {
      label: "Name",
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: "Active",
      name: "active",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const output = value ? <CheckIcon /> : null;
          return output;
        }
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

  const muiDatTab = (
    <MUIDataTable
      title="Schools"
      data={consent_forms}
      columns={columns}
      options={{
        responsive: "standard",
        filter: false,
        print: false,
        download: false,
        customToolbar: () => (
          <Tooltip title="New Consent Form">
            <IconButton
              id="new_consent_form"
              onClick={event => {
                navigate("new");
              }}
              aria-label="New Consent Form"
              size="large"
            >
              <AddIcon />
            </IconButton>
          </Tooltip>
        ),
        onCellClick: (colData, cellMeta) => {
          if ("Actions" != columns[cellMeta.colIndex].label) {
            const consent_form_id = consent_forms[cellMeta.dataIndex].id;
            navigate(String(consent_form_id));
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

ConsentFormList.propTypes = {};
