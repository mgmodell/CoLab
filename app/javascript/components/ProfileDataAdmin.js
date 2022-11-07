import React, { useState, useEffect } from "react";
import Button from "@mui/material/Button";
import PropTypes from "prop-types";
import Accordion from "@mui/material/Accordion";
import AccordionSummary from "@mui/material/AccordionSummary";
import AccordionDetails from "@mui/material/AccordionDetails";
import TextField from "@mui/material/TextField";
import InputLabel from "@mui/material/InputLabel";
import IconButton from "@mui/material/IconButton";
import FormControl from "@mui/material/FormControl";
import FormControlLabel from "@mui/material/FormControlLabel";
import Select from "@mui/material/Select";
import Switch from "@mui/material/Switch";
import Paper from "@mui/material/Paper";
import MenuItem from "@mui/material/MenuItem";
import FormHelperText from "@mui/material/FormHelperText";
import Collapse from "@mui/material/Collapse";
import Alert from "@mui/material/Alert";
import Tab from "@mui/material/Tab";
import ToggleButtonGroup from "@mui/material/ToggleButtonGroup";
import ToggleButton from "@mui/material/ToggleButton";
import UserEmailList from "./UserEmailList";

import CloseIcon from "@mui/icons-material/Close";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
const WorkingIndicator = React.lazy(() =>
  import("./infrastructure/WorkingIndicator")
);

import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";
import { TabList, TabContext, TabPanel } from "@mui/lab/";
import { Settings } from "luxon";

import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";
const UserCourseList = React.lazy(() => import("./UserCourseList"));
const ResearchParticipationList = React.lazy(() =>
  import("./ResearchParticipationList")
);
const UserActivityList = React.lazy(() => import("./UserActivityList"));
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusSlice";
import { Box, Grid, Link } from "@mui/material";
import { useTypedSelector } from "./infrastructure/AppReducers";
import {
  fetchProfile,
  setProfile,
  persistProfile,
  setLocalLanguage
} from "./infrastructure/ProfileSlice";
import { Skeleton } from "@mui/material";
import axios from "axios";

export default function ProfileDataAdmin(props) {
  const category = "profile";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const lookupStatus = useTypedSelector(
    state => state.context.status.lookupsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );

  const profileReady = endpointStatus && lookupStatus;
  const existingProfile = profileReady && undefined != user && user.id > 0;

  const timezones = useTypedSelector(state => state.context.lookups.timezones);
  const countries = useTypedSelector(state => state.context.lookups.countries);
  const cipCodes = useTypedSelector(state => state.context.lookups.cip_codes);
  const genders = useTypedSelector(state => state.context.lookups.genders);
  const schools = useTypedSelector(state => state.context.lookups.schools);
  const languages = useTypedSelector(state => state.context.lookups.languages);
  const themes = useTypedSelector(state => state.context.lookups.themes);

  const [states, setStates] = useState([]);

  const [courses, setCourses] = useState();

  const [activities, setActivities] = useState();

  const [consentForms, setConsentForms] = useState();

  //const { t, i18n } = useTranslation('profiles' );
  const dispatch = useDispatch();

  const [curTab, setCurTab] = useState("details");
  const [dirty, setDirty] = useState(false);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const [curPanel, setCurPanel] = useState("");

  const setProfileFirstName = first_name => {
    const temp = {};
    Object.assign(temp, user);
    temp.first_name = first_name;
    dispatch(setProfile(temp));
  };
  const setProfileLastName = last_name => {
    const temp = {};
    Object.assign(temp, user);
    temp.last_name = last_name;
    dispatch(setProfile(temp));
  };
  const setProfileEmails = emails => {
    const temp = {};
    Object.assign(temp, user);
    temp.emails = emails;
    dispatch(setProfile(temp));
  };
  const setProfileTimezone = timezone => {
    const temp = {};
    Object.assign(temp, user);
    temp.timezone = timezone;
    dispatch(setProfile(temp));
  };
  //Demographics
  const setProfileGender = gender => {
    const temp = {};
    Object.assign(temp, user);
    temp.gender = gender;
    dispatch(setProfile(temp));
  };
  const setProfileHomeCountry = homeCountry => {
    const temp = {};
    Object.assign(temp, user);
    temp.country = homeCountry;
    dispatch(setProfile(temp));
  };
  const setProfileHomeState = home_state_id => {
    const temp = {};
    Object.assign(temp, user);
    temp.home_state_id = home_state_id;
    dispatch(setProfile(temp));
  };
  const setProfileSchool = school_id => {
    const temp = {};
    Object.assign(temp, user);
    temp.school_id = school_id;
    dispatch(setProfile(temp));
  };
  const setProfileHomeLanguage = language_id => {
    const temp = {};
    Object.assign(temp, user);
    temp.primary_language_id = language_id;
    dispatch(setProfile(temp));
  };
  const setProfileCipCode = cip_code_id => {
    const temp = {};
    Object.assign(temp, user);
    temp.cip_code_id = cip_code_id;
    dispatch(setProfile(temp));
  };
  const setProfileDOB = date_of_birth => {
    const temp = {};
    Object.assign(temp, user);
    temp.date_of_birth = date_of_birth;
    dispatch(setProfile(temp));
  };
  const setProfileStartedSchool = started_school => {
    const temp = {};
    Object.assign(temp, user);
    temp.started_school = started_school;
    dispatch(setProfile(temp));
  };
  const setProfileImpVisual = impairment_visual => {
    const temp = {};
    Object.assign(temp, user);
    temp.impairment_visual = impairment_visual;
    dispatch(setProfile(temp));
  };
  const setProfileImpAuditory = impairment_auditory => {
    const temp = {};
    Object.assign(temp, user);
    temp.impairment_auditory = impairment_auditory;
    dispatch(setProfile(temp));
  };
  const setProfileImpMotor = impairment_motor => {
    const temp = {};
    Object.assign(temp, user);
    temp.impairment_motor = impairment_motor;
    dispatch(setProfile(temp));
  };
  const setProfileImpCognitive = impairment_cognitive => {
    const temp = {};
    Object.assign(temp, user);
    temp.impairment_cognitive = impairment_cognitive;
    dispatch(setProfile(temp));
  };
  const setProfileImpOther = impairment_other => {
    const temp = {};
    Object.assign(temp, user);
    temp.impairment_other = impairment_other;
    dispatch(setProfile(temp));
  };

  //Display
  const setProfileLanguage = language_id => {
    dispatch(setLocalLanguage(language_id));
  };
  const setProfileTheme = theme_id => {
    const temp = {};
    Object.assign(temp, user);
    temp.theme_id = theme_id;
    dispatch(setProfile(temp));
  };
  const setProfileResearcher = researcher => {
    const temp = {};
    Object.assign(temp, user);
    temp.researcher = researcher;
    dispatch(setProfile(temp));
  };

  const handlePanelClick = newPanel => {
    setCurPanel(newPanel != curPanel ? newPanel : "");
  };

  const getStates = countryCode => {
    if (endpointStatus) {
      if (!endpoints.statesForUrl || null !== countryCode) {
        dispatch(startTask());
        const url = endpoints.statesForUrl + countryCode + ".json";
        axios
          .get(url, {})
          .then(response => {
            const data = response.data;
            //Find the selected state in the retrieved list
            const foundSelectedStates = data.filter(item => {
              return (
                user.home_state_id === item.id ||
                item.code === "__:" + countryCode
              );
            });

            setStates(data);

            if (1 === foundSelectedStates.length) {
              setProfileHomeState(foundSelectedStates[0].id);
              setDirty(true);
            }
            dispatch(endTask("loading"));
          })
          .catch(error => {
            console.log("error", error);
          });
      } else {
        setStates([]);
      }
    }
  };

  const getProfile = () => {
    dispatch(fetchProfile);
  };
  const saveProfile = () => {
    dispatch(persistProfile());
  };

  useEffect(() => {
    if (endpointStatus) {
      dispatch(endTask("loading"));
      getProfile();
    }
  }, [endpointStatus]);

  useEffect(() => {
    if (null !== user.lastRetrieved && null !== tz_hash) {
      Settings.defaultZoneName = tz_hash[user.timezone];
    }
  }, [user.lastRetrieved, tz_hash]);

  useEffect(() => setDirty(true), [
    user
    //Demographics
  ]);

  useEffect(() => getStates(user.country), [user.country]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveProfile}>
      {null == user.id ? "Create" : "Save"} Profile
    </Button>
  ) : null;

  const detailsComponent = lookupStatus ? (
    <Paper>
      <Accordion expanded>
        <AccordionSummary id="profile">Edit your profile</AccordionSummary>
        <AccordionDetails>
          <Grid container spacing={3}>
            <Grid item sm={6} xs={12}>
              <TextField
                label="First Name"
                id="first-name"
                value={user.first_name}
                fullWidth
                onChange={event => setProfileFirstName(event.target.value)}
                error={null != messages["first_name"]}
                helperText={messages["first_name"]}
              />
            </Grid>
            <Grid item sm={6} xs={12}>
              <TextField
                label="Last Name"
                id="last-name"
                value={user.last_name}
                fullWidth
                onChange={event => setProfileLastName(event.target.value)}
                error={null != messages["last_name"]}
                helperText={messages["last_name"]}
              />
            </Grid>
          </Grid>
        </AccordionDetails>
      </Accordion>
      <Accordion
        expanded={"email" === curPanel}
        onChange={() => handlePanelClick("email")}
      >
        <AccordionSummary expandIcon={<ExpandMoreIcon />} id="email">
          Email Settings
        </AccordionSummary>
        <AccordionDetails>
          <Grid container spacing={3}>
            <Grid item xs={12}>
              {0 < user.emails.length ? (
                <UserEmailList
                  emailList={user.emails}
                  emailListUpdateFunc={setProfileEmails}
                  addMessagesFunc={setMessages}
                  addEmailUrl={endpoints["addEmailUrl"]}
                  removeEmailUrl={endpoints["removeEmailUrl"]}
                  primaryEmailUrl={endpoints["setPrimaryEmailUrl"]}
                />
              ) : null}
            </Grid>
            <Grid item xs={12}>
              <Link href={endpoints["passwordResetUrl"]}>
                Want to change your password? Click here and we'll email
                instructions.
              </Link>
            </Grid>
          </Grid>
        </AccordionDetails>
      </Accordion>
      <Accordion
        expanded={"display" === curPanel}
        onChange={() => handlePanelClick("display")}
      >
        <AccordionSummary expandIcon={<ExpandMoreIcon />} id="display">
          Display Settings
        </AccordionSummary>
        <AccordionDetails>
          <Grid container spacing={3}>
            <Grid item md={6} xs={12}>
              <FormControl fullWidth>
                <InputLabel htmlFor="profile_theme" id="profile_theme_lbl">
                  What UI theme would you like to use?
                </InputLabel>
                <Select
                  id="profile_theme"
                  value={user.theme_id || 0}
                  onChange={event =>
                    setProfileTheme(Number(event.target.value))
                  }
                >
                  <MenuItem value={0}>None Selected</MenuItem>
                  {themes.map(theme => {
                    return (
                      <MenuItem key={theme.code} value={theme.id}>
                        {theme.name}
                      </MenuItem>
                    );
                  })}
                </Select>
                <FormHelperText error={true}>
                  {messages["theme"]}
                </FormHelperText>
              </FormControl>
            </Grid>
            <Grid item md={6} xs={12}>
              <FormControl fullWidth>
                <InputLabel
                  htmlFor="profile_language"
                  id="profile_language_lbl"
                >
                  What language would you like to use for CoLab?
                </InputLabel>
                <Select
                  id="profile_language"
                  value={user.language_id || 0}
                  onChange={event =>
                    setProfileLanguage(Number(event.target.value))
                  }
                >
                  <MenuItem value={0}>None Selected</MenuItem>
                  {languages.map(language => {
                    return (
                      <MenuItem key={language.name} value={language.id}>
                        {language.name}
                      </MenuItem>
                    );
                  })}
                </Select>
                <FormHelperText error={true}>
                  {messages["language"]}
                </FormHelperText>
              </FormControl>
            </Grid>
            <Grid item xs={3}>
              <FormControlLabel
                control={
                  <Switch
                    checked={user.researcher}
                    onChange={event => setProfileResearcher(!profileResearcher)}
                    name="researcher"
                  />
                }
                label="Anonymize names?"
              />
            </Grid>
            <Grid item xs={9}>
              <FormControl fullWidth>
                <InputLabel
                  htmlFor="profile_timezone"
                  id="profile_timezone_lbl"
                >
                  Time Zone
                </InputLabel>
                <Select
                  id="profile_timezone"
                  value={user.timezone}
                  onChange={event =>
                    setProfileTimezone(String(event.target.value))
                  }
                >
                  <MenuItem value={0}>None Selected</MenuItem>
                  {timezones.map(timezone => {
                    return (
                      <MenuItem key={timezone.name} value={timezone.name}>
                        {timezone.name}
                      </MenuItem>
                    );
                  })}
                </Select>
                <FormHelperText error={true}>
                  {messages["timezone"]}
                </FormHelperText>
              </FormControl>
            </Grid>
          </Grid>
        </AccordionDetails>
      </Accordion>
      <Accordion
        expanded={"demographics" === curPanel}
        onChange={() => handlePanelClick("demographics")}
      >
        <AccordionSummary expandIcon={<ExpandMoreIcon />} id="demographics">
          Tell us about yourself, {user.first_name} (optional)
        </AccordionSummary>
        <AccordionDetails>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth>
                <InputLabel htmlFor="profile_school" id="profile_school_lbl">
                  Which school do you currently attend?
                </InputLabel>
                <Select
                  id="profile_school"
                  value={user.school_id || 0}
                  onChange={event =>
                    setProfileSchool(Number(event.target.value))
                  }
                >
                  <MenuItem value={0}>None Selected</MenuItem>
                  {schools.map(school => {
                    return (
                      <MenuItem key={school.name} value={school.id}>
                        {school.name}
                      </MenuItem>
                    );
                  })}
                </Select>
                <FormHelperText error={true}>
                  {messages["school_id"]}
                </FormHelperText>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth>
                <InputLabel
                  htmlFor="profile_cip_code"
                  id="profile_cip_code_lbl"
                >
                  What are you studying?
                </InputLabel>
                <Select
                  id="profile_cip_code"
                  value={user.cip_code_id || 0}
                  onChange={event =>
                    setProfileCipCode(Number(event.target.value))
                  }
                >
                  <MenuItem key={0} value={0}>
                    None Selected
                  </MenuItem>
                  {cipCodes.map(cipCode => {
                    return (
                      <MenuItem key={cipCode.code} value={cipCode.id}>
                        {cipCode.name}
                      </MenuItem>
                    );
                  })}
                </Select>
                <FormHelperText error={true}>
                  {messages["cip_code_id"]}
                </FormHelperText>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6}>
              <InputLabel
                htmlFor="profile_primary_start_school"
                id="profile_primary_start_school_lbl"
              >
                When did you begin your studies?
              </InputLabel>
              <LocalizationProvider dateAdapter={AdapterLuxon}>
                <DatePicker
                  clearable
                  value={user.started_school}
                  placeholder="Enter Date"
                  onChange={date => setProfileStartedSchool(date)}
                  inputFormat="MM/dd/yyyy"
                  renderInput={props => (
                    <TextField id="profile_primary_start_school" {...props} />
                  )}
                />
              </LocalizationProvider>
            </Grid>
            <Grid item xs={12} md={6}>
              <FormControl fullWidth>
                <InputLabel htmlFor="profile_country" id="profile_country_lbl">
                  What country and state do you call home?
                </InputLabel>
                <Select
                  id="profile_country"
                  value={user.country || 0}
                  onChange={event => {
                    const country = String(event.target.value);
                    setProfileHomeCountry(country);
                  }}
                >
                  <MenuItem value={0}>None Selected</MenuItem>
                  {countries.map(country => {
                    return (
                      <MenuItem key={country.id} value={country.code}>
                        {country.name}
                      </MenuItem>
                    );
                  })}
                </Select>
                <FormHelperText error={true}>
                  {messages["language"]}
                </FormHelperText>
              </FormControl>
            </Grid>
            <Grid item xs={12} md={6}>
              {states.length > 0 ? (
                <FormControl fullWidth>
                  <Select
                    id="profile_state"
                    value={user.home_state_id}
                    onChange={event => {
                      setProfileHomeState(Number(event.target.value));
                    }}
                  >
                    {states.map(state => {
                      return (
                        <MenuItem key={state.id} value={state.id}>
                          {state.name}
                        </MenuItem>
                      );
                    })}
                  </Select>
                  <FormHelperText error={true}>
                    {messages["language"]}
                  </FormHelperText>
                </FormControl>
              ) : null}
            </Grid>
            <Grid item xs={12} md={6}>
              <FormControl fullWidth>
                <InputLabel
                  htmlFor="profile_language"
                  id="profile_language_lbl"
                >
                  What language do you speak at home?
                </InputLabel>
                <Select
                  id="profile_language"
                  value={user.primary_language_id || 0}
                  onChange={event =>
                    setProfileHomeLanguage(Number(event.target.value))
                  }
                >
                  <MenuItem value={0}>None Selected</MenuItem>
                  {languages.map(language => {
                    return (
                      <MenuItem key={language.code} value={language.id}>
                        {language.name}
                      </MenuItem>
                    );
                  })}
                </Select>
                <FormHelperText error={true}>
                  {messages["language"]}
                </FormHelperText>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth>
                <InputLabel htmlFor="profile_gender" id="profile_gender_lbl">
                  What is your gender?
                </InputLabel>
                <Select
                  id="profile_gender"
                  value={user.gender_id || 0}
                  onChange={event =>
                    setProfileGender(Number(event.target.value))
                  }
                >
                  <MenuItem value={0}>None Selected</MenuItem>
                  {genders.map(gender => {
                    return (
                      <MenuItem key={gender.code} value={gender.id}>
                        {gender.name}
                      </MenuItem>
                    );
                  })}
                </Select>
                <FormHelperText error={true}>
                  {messages["language"]}
                </FormHelperText>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <InputLabel
                htmlFor="profile_date_of_birth"
                id="profile_date_of_birth_lbl"
              >
                When were you born?
              </InputLabel>
              <LocalizationProvider dateAdapter={AdapterLuxon}>
                <DatePicker
                  clearable
                  value={user.date_of_birth}
                  placeholder="Enter Date"
                  onChange={date => setProfileDOB(date)}
                  inputFormat="MM/dd/yyyy"
                  renderInput={props => (
                    <TextField id="profile_date_of_birth" {...props} />
                  )}
                />
              </LocalizationProvider>
            </Grid>
            <Grid item xs={12} md={12}>
              <InputLabel htmlFor="impairments">
                Do you have any impairments which alter your perspective?
              </InputLabel>
              <ToggleButtonGroup id="impairments">
                <ToggleButton
                  value="visual"
                  selected={user.impairment_visual}
                  onClick={() => {
                    setProfileImpVisual(!profileImpVisual);
                  }}
                >
                  Visual
                </ToggleButton>
                <ToggleButton
                  value="auditory"
                  selected={user.impairment_auditory}
                  onClick={() => {
                    setProfileImpAuditory(!profileImpAuditory);
                  }}
                >
                  Auditory
                </ToggleButton>
                <ToggleButton
                  value="cognitive"
                  selected={user.impairment_cognitive}
                  onClick={() => {
                    setProfileImpCognitive(!profileImpCognitive);
                  }}
                >
                  Cognitive
                </ToggleButton>
                <ToggleButton
                  value="motor"
                  selected={user.impairment_motor}
                  onClick={() => {
                    setProfileImpMotor(!profileImpMotor);
                  }}
                >
                  Motor
                </ToggleButton>
                <ToggleButton
                  value="other"
                  selected={user.impairment_other}
                  onClick={() => {
                    setProfileImpOther(!profileImpOther);
                  }}
                >
                  Other
                </ToggleButton>
              </ToggleButtonGroup>
            </Grid>
          </Grid>
        </AccordionDetails>
      </Accordion>
      &nbsp;
      <br />
      <br />
      {saveButton}
    </Paper>
  ) : null;

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
      <TabContext value={curTab}>
        <Box>
          <TabList
            centered
            value={curTab}
            onChange={(event, value) => setCurTab(value)}
          >
            <Tab label="Details" value="details" disabled={!profileReady} />
            <Tab
              label="My Courses"
              value="courses"
              disabled={!existingProfile}
            />
            <Tab label="History" value="history" disabled={!existingProfile} />
            <Tab
              label="Research Participation"
              value="research"
              disabled={!existingProfile}
            />
          </TabList>
        </Box>
        <TabPanel value="details">
          {profileReady ? (
            detailsComponent
          ) : (
            <Skeleton variant="rectangular" heght={300} />
          )}
        </TabPanel>
        <TabPanel value="courses">
          <UserCourseList
            retrievalUrl={endpoints["coursePerformanceUrl"] + ".json"}
            coursesList={courses}
            coursesListUpdateFunc={setCourses}
            addMessagesFunc={setMessages}
          />
        </TabPanel>
        <TabPanel value="history">
          <UserActivityList
            retrievalUrl={endpoints["activitiesUrl"] + ".json"}
            activitiesList={activities}
            activitiesListUpdateFunc={setActivities}
            addMessagesFunc={setMessages}
          />
        </TabPanel>
        <TabPanel value="research">
          <ResearchParticipationList
            retrievalUrl={endpoints["consentFormsUrl"] + ".json"}
            consentFormList={consentForms}
            consentFormListUpdateFunc={setConsentForms}
            addMessagesFunc={setMessages}
          />
        </TabPanel>
      </TabContext>
    </Paper>
  );
}

ProfileDataAdmin.propTypes = {
  profileId: PropTypes.number
};
