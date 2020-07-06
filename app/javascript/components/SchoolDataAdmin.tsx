import React, { useState, useEffect } from "react";
//Redux store stuff
import { useSelector, useDispatch } from 'react-redux';
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  acknowledgeMsg} from './infrastructure/StatusActions';
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import TextField from "@material-ui/core/TextField";
import InputLabel from "@material-ui/core/InputLabel";
import IconButton from "@material-ui/core/IconButton";
import FormControl from "@material-ui/core/FormControl";
import Select from "@material-ui/core/Select";
import Paper from "@material-ui/core/Paper";
import MenuItem from "@material-ui/core/MenuItem";
import FormHelperText from "@material-ui/core/FormHelperText";
import Collapse from "@material-ui/core/Collapse";
import Alert from "@material-ui/lab/Alert";
import CloseIcon from "@material-ui/icons/Close";

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import { useEndpointStore } from "./infrastructure/EndPointStore";
import { useStatusStore } from "./infrastructure/StatusStore";
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { useUserStore } from "./infrastructure/UserStore";
import { TextareaAutosize } from "@material-ui/core";

export default function SchoolDataAdmin(props) {
  const endpointSet = "school";
  const [endpoints, endpointsActions] = useEndpointStore();
  //const { t, i18n } = useTranslation('schools' );
  const [user, userActions] = useUserStore();

  const dirty = useSelector( state => state.dirtyState[ 'school' ] );
  const dispatch = useDispatch( );
  const [status, statusActions] = useStatusStore();

  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const [schoolId, setSchoolId] = useState(props.schoolId);
  const [schoolName, setSchoolName] = useState("");
  const [schoolDescription, setSchoolDescription] = useState("");
  const [schoolTimezone, setSchoolTimezone] = useState("UTC");

  const [timezones, setTimezones] = useState([]);

  const getSchool = () => {
    statusActions.startTask();
    dispatch( setDirty('school') );
    var url = endpoints.endpoints[endpointSet].baseUrl + "/";
    if (null == schoolId) {
      url = url + "new.json";
    } else {
      url = url + schoolId + ".json";
    }
    fetch(url, {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return response.json();
        }
      })
      .then(data => {
        const school = data.school;

        setTimezones(data.timezones);

        setSchoolName(school.name || "");
        setSchoolDescription(school.description || "");
        setSchoolTimezone(school.timezone || "UTC");

        statusActions.endTask();
        dispatch( setClean('school') );
      });
  };
  const saveSchool = () => {
    const method = null == schoolId ? "POST" : "PATCH";
    statusActions.startTask("saving");

    const url =
      endpoints.endpoints[endpointSet].baseUrl +
      "/" +
      (null == schoolId ? props.schoolId : schoolId) +
      ".json";

    fetch(url, {
      method: method,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        school: {
          name: schoolName,
          //school_id: schoolId,
          description: schoolDescription,
          timezone: schoolTimezone
        }
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          statusActions.endTask("saving");
        }
      })
      .then(data => {
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const school = data.school;
          setSchoolId(school.id);
          setSchoolName(school.name);
          setSchoolDescription(school.description);
          setSchoolTimezone(school.timezone);

          setShowErrors(true);
          setDirty(false);
          dispatch( setClean('school') );
          setMessages(data.messages);
          statusActions.endTask("saving");
        } else {
          setShowErrors(true);
          setMessages(data.messages);
          statusActions.endTask("saving");
        }
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
      getSchool();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  useEffect(() => {
    dispatch( setDirty('school' ) )
  }, [
    schoolName,
    schoolDescription,
    schoolTimezone
  ]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveSchool}>
      {null == schoolId ? "Create" : "Save"} School
    </Button>
  ) : null;

  const detailsComponent = (
    <Paper>
      <TextField
        label="School Name"
        id="school-name"
        value={schoolName}
        fullWidth={false}
        onChange={event => setSchoolName(event.target.value)}
        error={null != messages["name"]}
        helperText={messages["name"]}
      />
      &nbsp;
      <FormControl>
        <InputLabel htmlFor="school_timezone" id="school_timezone_lbl">
          Time Zone
        </InputLabel>
        <Select
          id="school_timezone"
          value={schoolTimezone}
          onChange={event => setSchoolTimezone(String(event.target.value))}
        >
          {timezones.map(timezone => {
            return (
              <MenuItem key={timezone.name} value={timezone.name}>
                {timezone.name}
              </MenuItem>
            );
          })}
        </Select>
        <FormHelperText error={true}>{messages["timezone"]}</FormHelperText>
      </FormControl>
      <br />
      <TextField
        id="school-description"
        placeholder="Enter a description of the school"
        multiline={true}
        rows={2}
        rowsMax={4}
        label="Description"
        value={schoolDescription}
        onChange={event => setSchoolDescription(event.target.value)}
        InputLabelProps={{
          shrink: true
        }}
        margin="normal"
      />
      <br />
      {saveButton}
    </Paper>
  );

  return (
    <Paper>
      <Collapse in={showErrors}>
        <Alert
          action={
            <IconButton
              id="error-close"
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
          {messages["main"]}
        </Alert>
      </Collapse>
      {detailsComponent}
    </Paper>
  );
}

SchoolDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  schoolId: PropTypes.number
};
