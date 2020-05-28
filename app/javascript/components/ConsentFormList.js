import React, { useState, useEffect } from "react";
import {
  useHistory,
  useRouteMatch
} from 'react-router-dom'
import PropTypes from "prop-types";
import Alert from "@material-ui/lab/Alert";
import IconButton from "@material-ui/core/IconButton";
import LinearProgress from "@material-ui/core/LinearProgress";
import Tooltip from "@material-ui/core/Tooltip";
import Settings from "luxon/src/settings.js";

import AddIcon from '@material-ui/icons/Add'
import CloseIcon from '@material-ui/icons/Close'
import CheckIcon from '@material-ui/icons/Check'

import { useEndpointStore } from "./EndPointStore";
import { useUserStore } from "./UserStore";
import MUIDataTable from "mui-datatables";
import Collapse from "@material-ui/core/Collapse";

export default function ConsentFormList(props) {
  const endpointSet = "consent_form";
  const [endpoints, endpointsActions] = useEndpointStore();

  const history = useHistory();
  const {path, url} = useRouteMatch( );

  const [user, userActions] = useUserStore();
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const [working, setWorking] = useState(true);
  const columns = [
    {
      label: "Name",
      name: "name",
      options: {
        filter: false,
      }
    },
    {
      label: "Active",
      name: "active",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const output = value ? <CheckIcon/> : null;
          return output;

        }
      }
    }
  ]

  const [consent_forms, setSchools] = useState([]);

  const getSchools = () => {
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
        setSchools(data);
        setWorking(false);
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      getSchools();
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
      data={consent_forms}
      columns={columns}
      options={{
        responsive: "scrollMaxHeight",
        filter: false,
        print: false,
        download: false,
        customToolbar: () => (
          <Tooltip title="New Consent Form">
            <IconButton
              id="new_consent_form"
              onClick={event => {
                history.push( 'new' );
                //window.location.href =
                //  endpoints.endpoints[endpointSet].consentFormCreateUrl;
              }}
              aria-label="New Consent Form"
            >
              <AddIcon />
            </IconButton>
          </Tooltip>
        ),
        onCellClick: (colData, cellMeta) => {
          if ("Actions" != columns[cellMeta.colIndex].label) {
            //const link =
            //  endpoints.endpoints[endpointSet].baseUrl +
            //  "/" +
            const consent_form_id =  consent_forms[cellMeta.dataIndex].id;
              history.push(
                path + '/' + consent_form_id
              )
            // if (null != link) {
              // window.location.href = link;
            // }
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
      {working ? <LinearProgress /> : null}
      <div style={{ maxWidth: "100%" }}>{muiDatTab}</div>
    </React.Fragment>
  );
}

ConsentFormList.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
