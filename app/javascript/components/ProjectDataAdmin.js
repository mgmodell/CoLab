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
import Tab from '@material-ui/core/Tab';
import Tabs from '@material-ui/core/Tabs';

import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from "@material-ui/pickers";

import DateTime from "luxon/src/datetime.js";
import Info from "luxon/src/info.js";

import LuxonUtils from "@date-io/luxon";
import { useUserStore } from "./UserStore";

import ProjectGroups from './ProjectGroups';

export default function ProjectDataAdmin(props) {
  const [curTab, setCurTab] = useState( 'details' );
  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [messages, setMessages] = useState( { } )
  const [factorPacks, setFactorPacks] = useState([
    { id: 0, name_en: "none selected" }
  ]);
  const [styles, setStyles] = useState([{ id: 0, name_en: "none selected" }]);
  const [projectId, setProjectId] = useState(props.projectId);
  const [projectName, setProjectName] = useState("");
  const [projectDescription, setProjectDescription] = useState("");
  const [projectStartDate, setProjectStartDate] = useState(
    DateTime.local().toJSDate()
  );
  //Using this Luxon function for later i18n
  const [daysOfWeek, setDaysOfWeek] = useState(Info.weekdays());
  const [projectEndDate, setProjectEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
      .toJSDate()
  );
  const [projectStartDOW, setProjectStartDOW] = useState(5);
  const [projectEndDOW, setProjectEndDOW] = useState(1);
  const [projectActive, setProjectActive] = useState(false);
  const [projectFactorPackId, setProjectFactorPackId] = useState(0);
  const [projectStyleId, setProjectStyleId] = useState(0);
  const [courseId, setCourseId] = useState(props.courseId);
  const [courseName, setCourseName] = useState('');
  const [user, userActions] = useUserStore();

  const getProject = () => {
    setDirty(true);
    var url = props.projectUrl + '/';
    if( null == projectId ){
      url = url + 'new.json?course_id=' + courseId;
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
          setMessages( { } );
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        const project = data.project;
        setFactorPacks(factorPacks.concat( data.factorPacks) );
        setStyles(styles.concat( data.styles) );

        setProjectName(project.name || '');
        setProjectDescription(project.description || '');
        setProjectActive(project.active);
        setProjectStartDate(DateTime.fromISO(project.start_date).toJSDate());
        setProjectEndDate(DateTime.fromISO(project.end_date).toJSDate());
        setProjectFactorPackId(project.factor_pack_id);
        setProjectStyleId(project.style_id);
        setProjectStartDOW(project.start_dow);
        setProjectEndDOW(project.end_dow);

        const course = data.course;
        setCourseId(course.id);
        setCourseName(course.name);
        setWorking(false);
        setDirty(false);
      });
  };
  const saveProject = () => {
    const method = null == projectId ? "POST" : "PATCH";
    setWorking(true);

    const url =
      props.projectUrl + (null == projectId ? '' : "/" + projectId) + ".json";

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
          setMessages( data.messages );
          console.log("error");
        }
      })
      .then(data => {
        if(null == data.messages){
        const project = data.project;
        setProjectId(project.id);
        setProjectName(project.name);
        setProjectDescription(project.description);
        setProjectActive(project.active);
        setProjectStartDate(DateTime.fromISO(project.start_date).toJSDate());
        setProjectEndDate(DateTime.fromISO(project.end_date).toJSDate());
        setProjectFactorPackId(project.factor_pack_id);
        setProjectStyleId(project.style_id);
        setProjectStartDOW(project.start_dow);
        setProjectEndDOW(project.end_dow);

        const course = data.course;
        setCourseId(course.id);
        setCourseName(course.name);
        setWorking(false);
        setDirty(false);
          setMessages( { } );
        }else{
          setMessages( data.messages );
        }
      });
  };
  useEffect(() => {
    daysOfWeek.unshift(daysOfWeek.pop());
    setDaysOfWeek(daysOfWeek);
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
    getProject();
  }, []);

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
      {null == projectId ? 'Create' : 'Save'} Project
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
        id='project-name'
        value={projectName}
        fullWidth={true}
        onChange={event => setProjectName(event.target.value)}
        error={null != messages.name}
        helperText={messages.name}
      />
      <TextField
        label="Project Description"
        id='project-description'
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

      <MuiPickersUtilsProvider utils={LuxonUtils}>
        <KeyboardDatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          format="MM/dd/yyyy"
          margin="normal"
          id='project_start_date'
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
          id='project_end_date'
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
    </Paper>
  )
  return (
    <Paper>
    <Tabs value={curTab} onChange={(event, value) => setCurTab(value)}>
      <Tab label='Details' value='details' />
      <Tab label='Groups' value='groups' disabled={null == projectId} />
    </Tabs>
      {'details' == curTab ? detailsComponent : null }
      {'groups' == curTab ? (
        <ProjectGroups
          token={props.token}
          projectId={projectId}
          groupsUrl={props.groupsUrl}
          diversityCheckUrl={props.diversityCheckUrl}
          diversityRescoreGroup={props.diversityRescoreGroup}
          diversityRescoreGroups={props.diversityRescoreGroups}

        /> ) : null }
    </Paper>
  );
}

ProjectDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  courseId: PropTypes.number,
  projectId: PropTypes.number,
  projectUrl: PropTypes.string.isRequired,
  activateProjectUrl: PropTypes.string.isRequired
};
