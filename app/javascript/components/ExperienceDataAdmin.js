import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import TextField from "@material-ui/core/TextField";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Switch from "@material-ui/core/Switch";
import Paper from "@material-ui/core/Paper";
import Tab from "@material-ui/core/Tab";
import Tabs from "@material-ui/core/Tabs";
import Typography from "@material-ui/core/Typography";
import FormHelperText from "@material-ui/core/FormHelperText";

import {
  DatePicker,
  LocalizationProvider
} from "@material-ui/pickers";

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";
import ReactionsList from "./ReactionsList";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import { useEndpointStore } from "./infrastructure/EndPointStore";
import { useStatusStore } from './infrastructure/StatusStore';
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { useUserStore } from "./infrastructure/UserStore";

export default function ExperienceDataAdmin(props) {
  const endpointSet = "experience_admin";
  const [endpoints, endpointsActions] = useEndpointStore();
  //const { t, i18n } = useTranslation('experiences' );
  const [user, userActions] = useUserStore();

  const [curTab, setCurTab] = useState("details");
  const [dirty, setDirty] = useState(false);
  const [status, statusActions] = useStatusStore( );
  const [messages, setMessages] = useState({});
  const [experienceId, setExperienceId] = useState(props.experienceId);
  const [experienceName, setExperienceName] = useState("");
  const [experienceLeadTime, setExperienceLeadTime] = useState(0);

  const [experienceStartDate, setExperienceStartDate] = useState(
    DateTime.local().toISO()
  );
  //Using this Luxon function for later i18n
  const [experienceEndDate, setExperienceEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
      .toISO()
  );
  const [experienceActive, setExperienceActive] = useState(false);
  const [reactionsUrl, setReactionsUrl] = useState();
  const [reactionData, setReactionData] = useState();
  const [courseName, setCourseName] = useState("");
  const [courseTimezone, setCourseTimezone] = useState("UTC");

  const getExperience = () => {
    setDirty(true);
    var url = endpoints.endpoints[endpointSet].baseUrl + "/";
    if (null == experienceId) {
      url = url + "new/" + props.courseId + ".json";
    } else {
      url = url + experienceId + ".json";
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
        const experience = data.experience;
        const course = data.course;

        setCourseName(course.name);
        setCourseTimezone(course.timezone);
        setReactionsUrl(data.reactionsUrl);
        Settings.defaultZoneName = course.timezone;

        setExperienceName(experience.name || "");
        setExperienceActive(experience.active || false);
        setExperienceLeadTime(experience.lead_time || 3);

        var receivedDate = DateTime.fromISO(experience.start_date).setZone(
          course.timezone
        );
        setExperienceStartDate(receivedDate.toISO());
        receivedDate = DateTime.fromISO(experience.end_date).setZone(
          course.timezone
        );
        setExperienceEndDate(receivedDate.toISO());

        statusActions.setWorking(false);
        setDirty(false);
      });
  };
  const saveExperience = () => {
    const method = null == experienceId ? "POST" : "PATCH";
    statusActions.setWorking(true);

    const url =
      endpoints.endpoints[endpointSet].baseUrl +
      "/" +
      (null == experienceId ? props.courseId : experienceId) +
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
        experience: {
          name: experienceName,
          course_id: props.courseId,
          lead_time: experienceLeadTime,
          active: experienceActive,
          start_date: experienceStartDate,
          end_date: experienceEndDate
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
          console.log( data );
          const experience = data.experience;
          setExperienceId(experience.id);
          setExperienceName(experience.name);
          setExperienceActive(experience.active);
          var receivedDate = DateTime.fromISO(experience.start_date).setZone(
            courseTimezone
          );
          setExperienceStartDate(receivedDate.toISO());
          receivedDate = DateTime.fromISO(experience.end_date).setZone(
            courseTimezone
          );
          setExperienceEndDate(receivedDate.toISO());

          const course = data.course;
          setCourseName(course.name);
          statusActions.setWorking(false);
          setDirty(false);
          setMessages(data.messages);
        } else {
          setMessages(data.messages);
          statusActions.setWorking(false);
        }
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      statusActions.setWorking( true );
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      getExperience();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  useEffect(() => setDirty(true), [
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
      <LocalizationProvider dateAdapter={LuxonUtils}>
        <DatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          inputFormat="MM/dd/yyyy"
          margin="normal"
          label="Experience Start Date"
          value={experienceStartDate}
          onChange={setExperienceStartDate}
          error={null != messages.start_date}
          helperText={messages.start_date}
          renderInput={props => <TextField
            id="experience_start_date"
            {...props} />}
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
          label="Experience End Date"
          value={experienceEndDate}
          onChange={setExperienceEndDate}
          error={null != messages.end_date}
          helperText={messages.end_date}
          renderInput={props => <TextField
            id="experience_end_date"
            {...props} />}
        />
      </LocalizationProvider>
      {null != messages.end_date ? (
        <FormHelperText error={true}>{messages.end_date}</FormHelperText>
      ) : null}
      <br />

      <br />
      {saveButton}
      {messages.status}
    </Paper>
  );

  const reactionListing =
    experienceId > 0 ? (
      <ReactionsList
        token={props.token}
        retrievalUrl={reactionsUrl}
        reactionsList={reactionData}
        reactionsListUpdateFunc={setReactionData}
      />
    ) : (
      "The Experience must be created before students can react to it."
    );
  return (
    <Paper>
      <Tabs value={curTab} onChange={(event, value) => setCurTab(value)}>
        <Tab label="Details" value="details" />
        <Tab label="Results" value="groups" disabled={null == experienceId} />
      </Tabs>
      {"details" == curTab ? detailsComponent : null}
      {"groups" == curTab ? { reactionListing } : null}
    </Paper>
  );
}

ExperienceDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  courseId: PropTypes.number.isRequired,
  experienceId: PropTypes.number
};
