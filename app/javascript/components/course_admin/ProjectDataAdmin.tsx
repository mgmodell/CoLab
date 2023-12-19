import React, { useState, useEffect, Suspense } from "react";
import axios from "axios";
import { useParams } from "react-router-dom";

import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import FormControlLabel from "@mui/material/FormControlLabel";
import Switch from "@mui/material/Switch";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import Select from "@mui/material/Select";
import Typography from "@mui/material/Typography";
import FormHelperText from "@mui/material/FormHelperText";

import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";

import { DateTime, Info, Settings } from "luxon";

import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";

import { Skeleton } from "@mui/material";
import { useTranslation } from "react-i18next";
import { TabPanel, TabView } from "primereact/tabview";
import { Panel } from "primereact/panel";

const ProjectGroups = React.lazy(() => import("./ProjectGroups"));
const ChartContainer = React.lazy(() => import("../Reports/ChartContainer"));

export default function ProjectDataAdmin(props) {
  const category = "project";
  const { t, i18n } = useTranslation(`${category}s`);
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { courseIdParam, projectIdParam } = useParams();

  const [curTab, setCurTab] = useState(0);
  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });
  const [messages, setMessages] = useState({});
  const dispatch = useDispatch();

  const [factorPacks, setFactorPacks] = useState([
    { id: 0, name: "none selected" }
  ]);
  const [styles, setStyles] = useState([{ id: 0, name_en: "none selected" }]);
  const [projectId, setProjectId] = useState(
    "new" === projectIdParam ? null : Number(projectIdParam)
  );
  const [projectName, setProjectName] = useState("");
  const [projectDescription, setProjectDescription] = useState("");
  const [projectStartDate, setProjectStartDate] = useState(DateTime.local());
  //Using this Luxon function for later i18n
  const [daysOfWeek, setDaysOfWeek] = useState(Info.weekdays());
  const [projectEndDate, setProjectEndDate] = useState(
    DateTime.local().plus({ month: 3 })
  );
  const [projectStartDOW, setProjectStartDOW] = useState(5);
  const [projectEndDOW, setProjectEndDOW] = useState(1);
  const [projectActive, setProjectActive] = useState(false);
  const [projectFactorPackId, setProjectFactorPackId] = useState(0);
  const [projectStyleId, setProjectStyleId] = useState(0);
  const [courseName, setCourseName] = useState("");
  const [courseTimezone, setCourseTimezone] = useState("UTC");

  const getProject = () => {
    dispatch(startTask());
    dispatch(setDirty(category));
    var url = endpoints.baseUrl + "/";
    if (null == projectId) {
      url = url + "new/" + courseIdParam + ".json";
    } else {
      url = url + projectId + ".json";
    }
    axios.get(url, {}).then(response => {
      const data = response.data;
      const project = response.data.project;
      setFactorPacks(factorPacks.concat(data.factorPacks));
      setStyles(styles.concat(data.styles));

      const course = data.course;
      setCourseName(course.name);
      setCourseTimezone(course.timezone);
      //Settings.defaultZone = course.timezone;

      setProjectName(project.name || "");
      setProjectDescription(project.description || "");
      setProjectActive(project.active);

      var receivedDate = DateTime.fromISO(project.start_date).setZone(
        course.timezone
      );
      setProjectStartDate(receivedDate);
      receivedDate = DateTime.fromISO(project.end_date).setZone(
        course.timezone
      );
      setProjectEndDate(receivedDate);
      setProjectFactorPackId(project.factor_pack_id);
      setProjectStyleId(project.style_id);
      setProjectStartDOW(project.start_dow);
      setProjectEndDOW(project.end_dow);
      dispatch(setClean(category));
    }).finally(() => {
      dispatch(endTask());
    })
  };
  const saveProject = () => {
    const method = null == projectId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null == projectId ? courseIdParam : projectId) +
      ".json";

    axios({
      method: method,
      url: url,
      data: {
        project: {
          name: projectName,
          course_id: courseIdParam,
          description: projectDescription,
          active: projectActive,
          start_date: projectStartDate.toJSDate(),
          end_date: projectEndDate,
          start_dow: projectStartDOW,
          end_dow: projectEndDOW,
          factor_pack_id: projectFactorPackId,
          style_id: projectStyleId
        }
      }
    })
      .then(response => {
        const data = response.data;
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const project = data.project;
          setProjectId(project.id);
          setProjectName(project.name);
          setProjectDescription(project.description);
          setProjectActive(project.active);
          var receivedDate = DateTime.fromISO(project.start_date).setZone(
            courseTimezone
          );
          setProjectStartDate(receivedDate);
          receivedDate = DateTime.fromISO(project.end_date).setZone(
            courseTimezone
          );
          setProjectEndDate(receivedDate);
          setProjectFactorPackId(project.factor_pack_id);
          setProjectStyleId(project.style_id);
          setProjectStartDOW(project.start_dow);
          setProjectEndDOW(project.end_dow);

          const course = data.course;
          setCourseName(course.name);
          dispatch(endTask("saving"));
          dispatch(setClean(category));
          setMessages(data.messages);
          dispatch(
            addMessage(data.messages.status, new Date(), Priorities.INFO)
          );
        } else {
          setMessages(data.messages);
          dispatch(
            addMessage(data.messages.status, new Date(), Priorities.ERROR)
          );
        }
      })
      .catch(error => {
        console.log("error", error);
      }).finally(() => {
        dispatch(endTask("saving"));
      })
  };
  useEffect(() => {
    daysOfWeek.unshift(daysOfWeek.pop());
    setDaysOfWeek(daysOfWeek);
  }, []);

  useEffect(() => {
    if (endpointStatus) {
      getProject();
    }
  }, [endpointStatus]);

  useEffect(() => {
    dispatch(setDirty(category));
  }, [
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
    <Panel>
      <TextField
        label="Project Name"
        id="name"
        value={projectName}
        fullWidth={true}
        onChange={event => setProjectName(event.target.value)}
        error={null != messages.name}
        helperText={messages.name}
      />
      <TextField
        label="Project Description"
        id="description"
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
      <LocalizationProvider dateAdapter={AdapterLuxon} adapterLocale={"en-us"}>
        <DatePicker
          format="MM/dd/yyyy"
          label={t("start_date_lbl")}
          value={projectStartDate}
          onChange={setProjectStartDate}
          error={Boolean(messages["start_date"])}
          helperText={messages["start_date"]}
          slot={{
            TextField: TextField
          }}
          slotProps={{
            textField: {
              id: "project_start_date"
            }
          }}
        />
        {null != messages.start_date ? (
          <FormHelperText error={true}>{messages.start_date}</FormHelperText>
        ) : null}

        <DatePicker
          format="MM/dd/yyyy"
          label={t("end_date_lbl")}
          value={projectEndDate}
          onChange={setProjectEndDate}
          error={Boolean(messages["end_date"])}
          helperText={messages["end_date"]}
          renderInput={props => <TextField id="project_end_date" {...props} />}
          slot={{
            TextField: TextField
          }}
          slotProps={{
            textField: {
              id: "project_end_date"
            }
          }}
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
    </Panel>
  );
  const chartContainer =
    0 < projectId && "" !== projectName ? (
      <React.Fragment>
        <Suspense fallback={<Skeleton variant="rectangular" height={300} />}>
          <ChartContainer
            unitOfAnalysis="group"
            anonymize={false}
            forResearch={false}
            projects={[{ id: projectId, name: projectName }]}
          />
        </Suspense>
      </React.Fragment>
    ) : null;

  return (
      <TabView activeIndex={curTab} onTabChange={event => setCurTab(event.index)}>
        <TabPanel header="Details">{detailsComponent}</TabPanel>
        <TabPanel header="Groups">
          <ProjectGroups
            projectId={projectId}
            groupsUrl={endpoints.groupsUrl}
            diversityCheckUrl={endpoints.diversityCheckUrl}
            diversityRescoreGroup={endpoints.diversityRescoreGroup}
            diversityRescoreGroups={endpoints.diversityRescoreGroups}
          />
        </TabPanel>
        <TabPanel header="Reporting">{chartContainer}</TabPanel>
      </TabView>

  );
}

ProjectDataAdmin.propTypes = {};
