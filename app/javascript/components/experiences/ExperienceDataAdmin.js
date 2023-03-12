import React, { useState, useEffect } from "react";
import { useParams } from "react-router-dom";
import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import FormControlLabel from "@mui/material/FormControlLabel";
import Switch from "@mui/material/Switch";
import Paper from "@mui/material/Paper";
import Tab from "@mui/material/Tab";
import Box from "@mui/material/Box";
import { TabList, TabContext, TabPanel } from "@mui/lab";
import Typography from "@mui/material/Typography";
import FormHelperText from "@mui/material/FormHelperText";

import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";

import { DateTime, Settings } from "luxon";
const ReactionsList = React.lazy(() => import("./ReactionsList"));

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
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { useTypedSelector } from "../infrastructure/AppReducers";
import axios from "axios";

export default function ExperienceDataAdmin(props) {
  const category = "experience_admin";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  //const { t, i18n } = useTranslation('experiences' );
  const user = useTypedSelector(state => state.profile.user);
  const userLoaded = useTypedSelector(state => {
    return null != state.profile.lastRetrieved;
  });
  const { experienceIdParam, courseIdParam } = useParams();

  const [curTab, setCurTab] = useState("details");
  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });
  const dispatch = useDispatch();
  const [messages, setMessages] = useState({});
  const [experienceId, setExperienceId] = useState(
    "new" === experienceIdParam ? null : experienceIdParam
  );
  const [experienceName, setExperienceName] = useState("");
  const [experienceLeadTime, setExperienceLeadTime] = useState(0);

  const [experienceStartDate, setExperienceStartDate] = useState(
    DateTime.local()
  );
  //Using this Luxon function for later i18n
  const [experienceEndDate, setExperienceEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
      
  );
  const [experienceActive, setExperienceActive] = useState(false);
  const [reactionsUrl, setReactionsUrl] = useState();
  const [reactionData, setReactionData] = useState();
  const [courseName, setCourseName] = useState("");
  const [courseTimezone, setCourseTimezone] = useState("UTC");

  const getExperience = () => {
    dispatch(startTask());
    dispatch(setDirty(category));
    var url = endpoints.baseUrl + "/";
    if (null == experienceId) {
      url = url + "new/" + courseIdParam + ".json";
    } else {
      url = url + experienceId + ".json";
    }
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const experience = data.experience;
        const course = data.course;

        setCourseName(course.name);
        setCourseTimezone(course.timezone);
        setReactionsUrl(data.reactionsUrl);
        Settings.defaultZone = course.timezone;

        setExperienceName(experience.name || "");
        setExperienceActive(experience.active || false);
        setExperienceLeadTime(experience.lead_time || 3);

        var receivedDate = DateTime.fromISO(experience.start_date).setZone(
          course.timezone
        );
        setExperienceStartDate(receivedDate);
        receivedDate = DateTime.fromISO(experience.end_date).setZone(
          course.timezone
        );
        setExperienceEndDate(receivedDate);

        dispatch(endTask());
        dispatch(setClean(category));
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(setClean(category));
      });
  };
  const saveExperience = () => {
    const method = null == experienceId ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url =
      endpoints.baseUrl +
      "/" +
      (null == experienceId ? courseIdParam : experienceId) +
      ".json";

    axios({
      url: url,
      method: method,
      data: {
        experience: {
          name: experienceName,
          course_id: courseIdParam,
          lead_time: experienceLeadTime,
          active: experienceActive,
          start_date: experienceStartDate,
          end_date: experienceEndDate
        }
      }
    })
      .then(response => {
        const data = response.data;
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const experience = data.experience;
          setExperienceId(experience.id);
          setExperienceName(experience.name);
          setExperienceActive(experience.active);
          var receivedDate = DateTime.fromISO(experience.start_date).setZone(
            courseTimezone
          );
          setExperienceStartDate(receivedDate);
          receivedDate = DateTime.fromISO(experience.end_date).setZone(
            courseTimezone
          );
          setExperienceEndDate(receivedDate);

          const course = data.course;
          setCourseName(course.name);
          dispatch(endTask("saving"));
          dispatch(
            addMessage(data.messages.status, new Date(), Priorities.INFO)
          );
          setMessages(data.messages);
          dispatch(setClean(category));
        } else {
          setMessages(data.messages);
          dispatch(
            addMessage(data.messages.status, new Date(), Priorities.ERROR)
          );
          dispatch(endTask("saving"));
        }
      })
      .catch(error => {
        console.log("error", error);
        setMessages(data.messages);
        dispatch(
          addMessage(data.messages.status, new Date(), Priorities.ERROR)
        );
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      getExperience();
    }
  }, [endpointStatus]);

  useEffect(() => {
    if (userLoaded) {
      Settings.defaultZone = user.timezone;
    }
  }, [userLoaded]);

  useEffect(() => {
    dispatch(setDirty(category));
  }, [
    experienceName,
    experienceLeadTime,
    experienceActive,
    experienceStartDate,
    experienceEndDate
  ]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveExperience}>
      {null == experienceId ? "Create" : "Save"} Experience
    </Button>
  ) : null;

  //Later I want to call the activate/deactivate right here
  const toggleActive = () => {
    setExperienceActive(!experienceActive);
  };

  const detailsComponent = (
    <Paper>
      <TextField
        label="Experience Name"
        id="experience-name"
        value={experienceName}
        fullWidth={true}
        onChange={event => setExperienceName(event.target.value)}
        error={null != messages.name}
        helperText={messages.name}
      />
      <TextField
        id="experience-lead-time"
        //label={t('lead_time')}
        label="Days for instructor prep"
        value={experienceLeadTime}
        type="number"
        onChange={event => setExperienceLeadTime(event.target.value)}
        InputLabelProps={{
          shrink: true
        }}
        margin="normal"
      />
      <FormControlLabel
        control={
          <Switch checked={experienceActive} onChange={() => toggleActive()} />
        }
        label="Active"
      />

      <Typography>All dates shown in {courseTimezone} timezone.</Typography>
      <LocalizationProvider dateAdapter={AdapterLuxon}>
        <DatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          format="MM/dd/yyyy"
          margin="normal"
          label="Experience Start Date"
          value={experienceStartDate}
          onChange={setExperienceStartDate}
          error={null != messages.start_date}
          helperText={messages.start_date}
          renderInput={props => (
            <TextField id="experience_start_date" {...props} />
          )}
        />
      </LocalizationProvider>
      {null != messages.start_date ? (
        <FormHelperText error={true}>{messages.start_date}</FormHelperText>
      ) : null}

      <LocalizationProvider dateAdapter={AdapterLuxon}>
        <DatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          format="MM/dd/yyyy"
          margin="normal"
          label="Experience End Date"
          value={experienceEndDate}
          onChange={setExperienceEndDate}
          error={null != messages.end_date}
          helperText={messages.end_date}
          renderInput={props => (
            <TextField id="experience_end_date" {...props} />
          )}
        />
      </LocalizationProvider>
      {null != messages.end_date ? (
        <FormHelperText error={true}>{messages.end_date}</FormHelperText>
      ) : null}
      <br />

      <br />
      {saveButton}
    </Paper>
  );

  const reactionListing =
    reactionsUrl != undefined && experienceId > 0 ? (
      <ReactionsList
        retrievalUrl={reactionsUrl}
        reactionsList={reactionData}
        reactionsListUpdateFunc={setReactionData}
      />
    ) : (
      "The Experience must be created before students can react to it."
    );
  return (
    <Paper>
      <TabContext value={curTab}>
        <Box>
          <TabList value={curTab} onChange={(event, value) => setCurTab(value)}>
            <Tab label="Details" value="details" />
            <Tab
              label="Results"
              value="results"
              disabled={null == experienceId}
            />
          </TabList>
        </Box>
        <TabPanel value="details">{detailsComponent}</TabPanel>
        <TabPanel value="results">{reactionListing}</TabPanel>
      </TabContext>
    </Paper>
  );
}

ExperienceDataAdmin.propTypes = {};
