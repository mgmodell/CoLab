import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
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
import FormHelperText from "@material-ui/core/FormHelperText";

import { DatePicker, LocalizationProvider } from "@material-ui/pickers";

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import {useDispatch} from 'react-redux';
import {startTask, endTask} from './infrastructure/StatusActions';

import ProjectGroups from "./ProjectGroups";
import { useTypedSelector } from "./infrastructure/AppReducers";

export default function ProjectDataAdmin(props) {
  const cityTimezones = require("city-timezones");

  const endpointSet = "project";
  const endpoints = useTypedSelector(state=>state['resources'].endpoints[endpointSet])
  const endpointStatus = useTypedSelector(state=>state['resources'].endpoints_loaded)

  const [curTab, setCurTab] = useState("details");
  const [dirty, setDirty] = useState(false);
  const dispatch = useDispatch( );
  const [messages, setMessages] = useState({});
  const [factorPacks, setFactorPacks] = useState([
    { id: 0, name_en: "none selected" }
  ]);
  const [styles, setStyles] = useState([{ id: 0, name_en: "none selected" }]);
  const [projectId, setProjectId] = useState(props.projectId);
  const [projectName, setProjectName] = useState("");
  const [projectDescription, setProjectDescription] = useState("");
  const [projectStartDate, setProjectStartDate] = useState(
    DateTime.local().toISO()
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
  const [courseName, setCourseName] = useState("");
  const [courseTimezone, setCourseTimezone] = useState("UTC");

  const getProject = () => {
    dispatch( startTask() );
    setDirty(true);
    var url = endpoints.baseUrl + "/";
    if (null == projectId) {
      url = url + "new/" + props.courseId + ".json";
    } else {
      url = url + projectId + ".json";
    }
    fetch(url, {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
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
        setCourseName(course.name);
        setCourseTimezone(course.timezone);
        Settings.defaultZoneName = course.timezone;

        setProjectName(project.name || "");
        setProjectDescription(project.description || "");
        setProjectActive(project.active);

        var receivedDate = DateTime.fromISO(project.start_date).setZone(
          course.timezone
        );
        setProjectStartDate(receivedDate.toISO());
        receivedDate = DateTime.fromISO(project.end_date).setZone(
          course.timezone
        );
        setProjectEndDate(receivedDate.toISO());
        setProjectFactorPackId(project.factor_pack_id);
        setProjectStyleId(project.style_id);
        setProjectStartDOW(project.start_dow);
        setProjectEndDOW(project.end_dow);
        dispatch( endTask() );
        setDirty(false);
      });
  };
  const saveProject = () => {
    const method = null == projectId ? "POST" : "PATCH";
    dispatch( startTask("saving") );

    const url =
      endpoints.baseUrl +
      "/" +
      (null == projectId ? props.courseId : projectId) +
      ".json";

    fetch(url, {
      method: method,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
      },
      body: JSON.stringify({
        project: {
          name: projectName,
          course_id: props.courseId,
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
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const project = data.project;
          setProjectId(project.id);
          setProjectName(project.name);
          setProjectDescription(project.description);
          setProjectActive(project.active);
          var receivedDate = DateTime.fromISO(project.start_date).setZone(
            courseTimezone
          );
          setProjectStartDate(receivedDate.toISO());
          receivedDate = DateTime.fromISO(project.end_date).setZone(
            courseTimezone
          );
          setProjectEndDate(receivedDate.toISO());
          setProjectFactorPackId(project.factor_pack_id);
          setProjectStyleId(project.style_id);
          setProjectStartDOW(project.start_dow);
          setProjectEndDOW(project.end_dow);

          const course = data.course;
          setCourseName(course.name);
          dispatch( endTask("saving") );
          setDirty(false);
          setMessages(data.messages);
        } else {
          setMessages(data.messages);
          dispatch( endTask("saving") );
        }
      });
  };
  useEffect(() => {
    daysOfWeek.unshift(daysOfWeek.pop());
    setDaysOfWeek(daysOfWeek);
  }, []);

  useEffect(() => {
    if (endpointStatus ){
      getProject();
    }
  }, [endpointStatus ]);

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
      <LocalizationProvider dateAdapter={LuxonUtils}>
        <DatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          inputFormat="MM/dd/yyyy"
          margin="normal"
          label="Project Start Date"
          value={projectStartDate}
          onChange={setProjectStartDate}
          error={null != messages.start_date}
          helperText={messages.start_date}
          renderInput={props => (
            <TextField id="project_start_date" {...props} />
          )}
        />
      </LocalizationProvider>
      {null != messages.start_date ? (
        <FormHelperText error={true}>{messages.start_date}</FormHelperText>
      ) : null}

      <LocalizationProvider dateAdapter={LuxonUtils}>
        <DatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          inputFormat="MM/dd/yyyy"
          margin="normal"
          label="Project End Date"
          value={projectEndDate}
          onChange={setProjectEndDate}
          error={null != messages.end_date}
          helperText={messages.end_date}
          renderInput={props => <TextField id="project_end_date" {...props} />}
        />
      </LocalizationProvider>
      {null != messages.end_date ? (
        <FormHelperText error={true}>{messages.end_date}</FormHelperText>
      ) : null}
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
          projectId={projectId}
          groupsUrl={endpoints.groupsUrl}
          diversityCheckUrl={endpoints.diversityCheckUrl}
          diversityRescoreGroup={
            endpoints.diversityRescoreGroup
          }
          diversityRescoreGroups={
            endpoints.diversityRescoreGroups
          }
        />
      ) : null}
    </Paper>
  );
}

ProjectDataAdmin.propTypes = {
  courseId: PropTypes.number.isRequired,
  projectId: PropTypes.number
};
