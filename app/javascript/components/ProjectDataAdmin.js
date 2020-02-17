import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import TextField from "@material-ui/core/TextField";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Switch from "@material-ui/core/Switch";
import InputLabel from "@material-ui/core/InputLabel";
import MenuItem from "@material-ui/core/MenuItem";
import Select from "@material-ui/core/Select";
import Paper from "@material-ui/core/Paper";
import Tab from "@material-ui/core/Tab";
import Tabs from "@material-ui/core/Tabs";
import Typography from "@material-ui/core/Typography";

import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from "@material-ui/pickers";

import { DateTime, Info } from "luxon";
import Settings from 'luxon/src/settings.js'


import LuxonUtils from "@date-io/luxon";
import { useEndpointStore } from "./EndPointStore"

import ProjectGroups from "./ProjectGroups";

export default function ProjectDataAdmin(props) {
  const cityTimezones = require('city-timezones');

  const endpointSet = 'project';
  const [endpoints, endpointsActions] = useEndpointStore();

  const [curTab, setCurTab] = useState("details");
  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [messages, setMessages] = useState({});
  const [factorPacks, setFactorPacks] = useState([
    { id: 0, name_en: "none selected" }
  ]);
  const [styles, setStyles] = useState([{ id: 0, name_en: "none selected" }]);
  const [projectId, setProjectId] = useState(props.projectId);
  const [projectName, setProjectName] = useState("");
  const [projectDescription, setProjectDescription] = useState("");
  const [projectStartDate, setProjectStartDate] = useState(
    DateTime.local().toISO( )
  );
  //Using this Luxon function for later i18n
  const [daysOfWeek, setDaysOfWeek] = useState(Info.weekdays());
  const [projectEndDate, setProjectEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
      .toISO()
  );
  const [projectStartDOW, setProjectStartDOW] = useState(5);
  const [projectEndDOW, setProjectEndDOW] = useState(1);
  const [projectActive, setProjectActive] = useState(false);
  const [projectFactorPackId, setProjectFactorPackId] = useState(0);
  const [projectStyleId, setProjectStyleId] = useState(0);
  const [courseId, setCourseId] = useState(props.courseId);
  const [courseName, setCourseName] = useState("");
  const [courseTimezone, setCourseTimezone] = useState( 'UTC');

  const getProject = () => {
    setDirty(true);
    var url = endpoints.endpoints['project'].projectUrl + "/";
    if (null == projectId) {
      url = url + "new.json?course_id=" + courseId;
    } else {
      url = url + projectId + ".json";
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
        }
      })
      .then(data => {
        const project = data.project;
        setFactorPacks(factorPacks.concat(data.factorPacks));
        setStyles(styles.concat(data.styles));

        const course = data.course;
        setCourseId(course.id);
        setCourseName(course.name);
        console.log( course.timezone )
        console.log( DateTime.local( ).setZone( course.timezone ).isValid )
        setCourseTimezone( course.timezone );
        Settings.defaultZoneName = course.timezone;

        setProjectName(project.name || "");
        setProjectDescription(project.description || "");
        setProjectActive(project.active);

        console.log( DateTime.fromISO( project.start_date).setZone( course.timezone ))

        var receivedDate = DateTime.fromISO( project.start_date).setZone( course.timezone )
        setProjectStartDate(receivedDate.toISO() );
        console.log( course.timezone )
        console.log( receivedDate.toISO() )
        receivedDate = DateTime.fromISO( project.end_date).setZone( course.timezone )
        setProjectEndDate(receivedDate.toISO() );
        setProjectFactorPackId(project.factor_pack_id);
        setProjectStyleId(project.style_id);
        setProjectStartDOW(project.start_dow);
        setProjectEndDOW(project.end_dow);
        setWorking(false);
        setDirty(false);
      });
  };
  const saveProject = () => {
    const method = null == projectId ? "POST" : "PATCH";
    setWorking(true);

    const url =
    endpoints.endpoints['project'].projectUrl + (null == projectId ? "" : "/" + projectId) + ".json";

    fetch(url, {
      method: method,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        project: {
          name: projectName,
          course_id: courseId,
          description: projectDescription,
          active: projectActive,
          start_date: projectStartDate,
          end_date: projectEndDate,
          start_dow: projectStartDOW,
          end_dow: projectEndDOW,
          factor_pack_id: projectFactorPackId,
          style_id: projectStyleId
        }
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          setMessages(data.messages);
          console.log("error");
        }
      })
      .then(data => {
        if (data.messages == null || Object.keys(data.messages).length < 2) {
          const project = data.project;
          setProjectId(project.id);
          setProjectName(project.name);
          setProjectDescription(project.description);
          setProjectActive(project.active);
          console.log( 'save response')
          var receivedDate = DateTime.fromISO( project.start_date).setZone( courseTimezone )
          setProjectStartDate(receivedDate.toISO());
          receivedDate = DateTime.fromISO( project.end_date).setZone( courseTimezone )
          setProjectEndDate(receivedDate.toISO());
          setProjectFactorPackId(project.factor_pack_id);
          setProjectStyleId(project.style_id);
          setProjectStartDOW(project.start_dow);
          setProjectEndDOW(project.end_dow);

          const course = data.course;
          setCourseId(course.id);
          setCourseName(course.name);
          setWorking(false);
          setDirty(false);
          setMessages(data.messages);
        } else {
          setMessages(data.messages);
        }
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != 'loaded') {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }

    daysOfWeek.unshift(daysOfWeek.pop());
    setDaysOfWeek(daysOfWeek);

    //getProject();
  }, []);

  useEffect(() =>{
    if (endpoints.endpointStatus[endpointSet] == 'loaded') {
      getProject();
    }
  }, [
    endpoints.endpointStatus[endpointSet]
  ]);

  useEffect(() => setDirty(true), [
    projectName,
    projectDescription,
    projectActive,
    projectStyleId,
    projectFactorPackId,
    projectStartDate,
    projectEndDate,
    projectStartDOW,
    projectEndDOW
  ]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveProject}>
      {null == projectId ? "Create" : "Save"} Project
    </Button>
  ) : null;

  //Later I want to call the activate/deactivate right here
  const toggleActive = () => {
    setProjectActive(!projectActive);
  };

  const detailsComponent = (
    <Paper>
      {working ? <LinearProgress /> : null}
      <TextField
        label="Project Name"
        id="project-name"
        value={projectName}
        fullWidth={true}
        onChange={event => setProjectName(event.target.value)}
        error={null != messages.name}
        helperText={messages.name}
      />
      <TextField
        label="Project Description"
        id="project-description"
        value={projectDescription}
        fullWidth={true}
        onChange={event => setProjectDescription(event.target.value)}
        error={null != messages.description}
        helperText={messages.description}
      />
      <FormControlLabel
        control={
          <Switch checked={projectActive} onChange={() => toggleActive()} />
        }
        label="Active"
      />

      <Typography>All dates shown in {courseTimezone} timezone.</Typography>
      <MuiPickersUtilsProvider utils={LuxonUtils}>
        <KeyboardDatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          format="MM/dd/yyyy"
          margin="normal"
          id="project_start_date"
          label="Project Start Date"
          value={projectStartDate}
          onChange={setProjectStartDate}
          error={null != messages.start_date}
          helperText={messages.start_date}
        />
        <KeyboardDatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          format="MM/dd/yyyy"
          margin="normal"
          id="project_end_date"
          label="Project End Date"
          value={projectEndDate}
          onChange={setProjectEndDate}
          error={null != messages.end_date}
          helperText={messages.end_date}
        />
      </MuiPickersUtilsProvider>
      <br />
      <InputLabel htmlFor="start_dow">Opens every</InputLabel>
      <Select
        id="start_dow"
        onChange={event => setProjectStartDOW(event.target.value)}
        value={projectStartDOW}
      >
        {daysOfWeek.map((day, index) => {
          return (
            <MenuItem key={index} value={index}>
              {day}
            </MenuItem>
          );
        })}
      </Select>
      <InputLabel htmlFor="end_dow">Closes every</InputLabel>
      <Select
        id="end_dow"
        onChange={event => setProjectEndDOW(event.target.value)}
        value={projectEndDOW}
      >
        {daysOfWeek.map((day, index) => {
          return (
            <MenuItem key={index} value={index}>
              {day}
            </MenuItem>
          );
        })}
      </Select>

      <InputLabel htmlFor="style">Style</InputLabel>
      <Select
        id="style"
        disabled
        onChange={event => setProjectStyleId(event.target.value)}
        value={projectStyleId}
      >
        {styles.map(style => {
          return (
            <MenuItem key={style.id} value={style.id}>
              {style.name}
            </MenuItem>
          );
        })}
      </Select>
      <InputLabel htmlFor="factor_pack">Factor pack</InputLabel>
      <Select
        id="factor_pack"
        onChange={event => setProjectFactorPackId(event.target.value)}
        value={projectFactorPackId}
      >
        {factorPacks.map(factorPack => {
          return (
            <MenuItem key={factorPack.id} value={factorPack.id}>
              {factorPack.name}
            </MenuItem>
          );
        })}
      </Select>
      <br />
      {saveButton}
      {messages.status}
    </Paper>
  );
  return (
    <Paper>
      <Tabs value={curTab} onChange={(event, value) => setCurTab(value)}>
        <Tab label="Details" value="details" />
        <Tab label="Groups" value="groups" disabled={null == projectId} />
      </Tabs>
      {"details" == curTab ? detailsComponent : null}
      {"groups" == curTab ? (
        <ProjectGroups
          token={props.token}
          projectId={projectId}
          groupsUrl={endpoints.endpoints['project'].groupsUrl}
          diversityCheckUrl={endpoints.endpoints['project'].diversityCheckUrl}
          diversityRescoreGroup={endpoints.endpoints['project'].diversityRescoreGroup}
          diversityRescoreGroups={endpoints.endpoints['project'].diversityRescoreGroups}
        />
      ) : null}
    </Paper>
  );
}

ProjectDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  courseId: PropTypes.number.isRequired,
  projectId: PropTypes.number
};
