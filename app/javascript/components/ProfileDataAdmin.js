import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Accordion from "@material-ui/core/Accordion";
import AccordionSummary from "@material-ui/core/AccordionSummary";
import AccordionDetails from "@material-ui/core/AccordionDetails";
import TextField from "@material-ui/core/TextField";
import InputLabel from "@material-ui/core/InputLabel";
import IconButton from "@material-ui/core/IconButton";
import FormControl from "@material-ui/core/FormControl";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Select from "@material-ui/core/Select";
import Switch from "@material-ui/core/Switch";
import Paper from "@material-ui/core/Paper";
import MenuItem from "@material-ui/core/MenuItem";
import FormHelperText from "@material-ui/core/FormHelperText";
import Collapse from "@material-ui/core/Collapse";
import Alert from "@material-ui/lab/Alert";
import Tabs from "@material-ui/core/Tabs";
import Tab from "@material-ui/core/Tab";
import ToggleButtonGroup from "@material-ui/lab/ToggleButtonGroup";
import ToggleButton from "@material-ui/lab/ToggleButton";
import UserEmailList from "./UserEmailList";

import CloseIcon from "@material-ui/icons/Close";
import ExpandMoreIcon from "@material-ui/icons/ExpandMore";

import { DatePicker, LocalizationProvider } from "@material-ui/pickers";
import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";

import LuxonUtils from "@material-ui/pickers/adapter/luxon";
import { useEndpointStore } from "./infrastructure/EndPointStore";
import UserCourseList from "./UserCourseList";
import ResearchParticipationList from "./ResearchParticipationList";
import UserActivityList from "./UserActivityList";
//import i18n from './i18n';
//import { useTranslation } from 'react-i18next';
import { useUserStore } from "./infrastructure/UserStore";
import { useStatusStore } from "./infrastructure/StatusStore";
import { Grid, Link } from "@material-ui/core";

export default function ProfileDataAdmin(props) {
  const endpointSet = "profile";
  const [endpoints, endpointsActions] = useEndpointStore();
  //const { t, i18n } = useTranslation('profiles' );
  const [user, userActions] = useUserStore();
  const [status, statusActions] = useStatusStore();

  const [curTab, setCurTab] = useState("details");
  const [dirty, setDirty] = useState(false);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const [curPanel, setCurPanel] = useState("");

  const [profileId, setProfileId] = useState(props.profileId);
  const [profileFirstName, setProfileFirstName] = useState("");
  const [profileLastName, setProfileLastName] = useState("");
  const [profileEmails, setProfileEmails] = useState([]);
  //Demographics
  const [profileGender, setProfileGender] = useState(0);
  const [profileHomeCountry, setProfileHomeCountry] = useState("");
  const [profileHomeState, setProfileHomeState] = useState(0);
  const [profileSchool, setProfileSchool] = useState(0);
  const [profileHomeLanguage, setProfileHomeLanguage] = useState(0);
  const [profileCipCode, setProfileCipCode] = useState(0);
  const [profileDOB, setProfileDOB] = useState(new Date());
  const [profileStartedSchool, setProfileStartedSchool] = useState(new Date());

  const [profileImpVisual, setProfileImpVisual] = useState(false);
  const [profileImpAuditory, setProfileImpAuditory] = useState(false);
  const [profileImpMotor, setProfileImpMotor] = useState(false);
  const [profileImpCognitive, setProfileImpCognitive] = useState(false);
  const [profileImpOther, setProfileImpOther] = useState(false);

  //Display
  const [profileTheme, setProfileTheme] = useState(0);
  const [profileLanguage, setProfileLanguage] = useState(0);
  const [profileResearcher, setProfileResearcher] = useState(false);

  const [addEmailUrl, setAddEmailUrl] = useState("");
  const [removeEmailUrl, setRemoveEmailUrl] = useState("");
  const [primaryEmailUrl, setPrimaryEmailUrl] = useState("");
  const [passwordResetUrl, setPasswordResetUrl] = useState("");
  const [statesForUrl, setStatesForUrl] = useState("");

  const [coursePerformanceUrl, setCoursePerformanceUrl] = useState("");
  const [courses, setCourses] = useState();

  const [activitiesUrl, setActivitiesUrl] = useState("");
  const [activities, setActivities] = useState();

  const [consentFormsUrl, setConsentFormsUrl] = useState("");
  const [consentForms, setConsentForms] = useState();

  const [profileTimezone, setProfileTimezone] = useState("0");

  const [timezones, setTimezones] = useState([]);
  const [countries, setCountries] = useState([]);
  const [states, setStates] = useState([]);
  const [cipCodes, setCipCodes] = useState([]);
  const [genders, setGenders] = useState([]);
  const [schools, setSchools] = useState([]);
  const [languages, setLanguages] = useState([]);
  const [themes, setThemes] = useState([]);

  const handlePanelClick = newPanel => {
    setCurPanel(newPanel != curPanel ? newPanel : "");
  };

  const getStates = countryCode => {
    if ("" != statesForUrl) {
      statusActions.startTask();
      const url = statesForUrl + countryCode + ".json";
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
          //Find the selected state in the retrieved list
          const foundSelectedStates = data.filter(item => {
            return (
              profileHomeState === item.id || item.code === "__:" + countryCode
            );
          });

          setStates(data);

          if (1 === foundSelectedStates.length) {
            setProfileHomeState(foundSelectedStates[0].id);
            setDirty(true);
          }
          statusActions.endTask("loading");
        });
    }
  };

  const setProfileFields = profile => {
    setProfileFirstName(profile.first_name || "");
    setProfileLastName(profile.last_name || "");

    //Display
    setProfileTimezone(profile.timezone || "UTC");
    setProfileTheme(profile.theme_id);
    setProfileLanguage(profile.language_id);
    setProfileResearcher(profile.researcher || false);

    //Demographics
    setProfileGender(profile.gender_id || "");
    setProfileDOB(profile.date_of_birth);
    if (null != profile.emails) {
      setProfileEmails(profile.emails);
    }

    setProfileHomeLanguage(profile.primary_language_id);
    setProfileHomeCountry(profile.country);
    setProfileHomeState(profile.home_state_id);
    //getStates( profile.home_state_id );

    setProfileSchool(profile.school_id);
    setProfileCipCode(profile.cip_code_id);
    setProfileGender(profile.gender_id);
    setProfileStartedSchool(profile.started_school);

    //Impairments
    setProfileImpVisual(profile.impairment_visual);
    setProfileImpAuditory(profile.impairment_auditory);
    setProfileImpCognitive(profile.impairment_cognitive);
    setProfileImpMotor(profile.impairment_motor);
    setProfileImpOther(profile.impairment_other);
  };
  const getProfile = () => {
    setDirty(true);
    const url = endpoints.endpoints[endpointSet].baseUrl + ".json";
    statusActions.startTask();
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
        const profile = data.user;

        setAddEmailUrl(data.addEmailUrl);
        setRemoveEmailUrl(data.removeEmailUrl);
        setPrimaryEmailUrl(data.setPrimaryEmailUrl);
        setPasswordResetUrl(data.passwordResetUrl);
        setStatesForUrl(data.statesForUrl);

        setCoursePerformanceUrl(data.coursePerformanceUrl);
        setActivitiesUrl(data.activitiesUrl);
        setConsentFormsUrl(data.consentFormsUrl);

        setTimezones(data.timezones);
        setCountries(data.countries);
        setLanguages(data.languages);
        setCipCodes(data.cipCodes);
        setGenders(data.genders);
        setThemes(data.themes);
        setSchools(data.schools);

        setProfileFields(profile);

        statusActions.endTask("loading");
        setDirty(false);
      });
  };
  const saveProfile = () => {
    statusActions.startTask("saving");
    const url = endpoints.endpoints[endpointSet].baseUrl + ".json";
    console.log(url);

    fetch(url, {
      method: "PATCH",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        user: {
          //Display
          first_name: profileFirstName,
          last_name: profileLastName,

          //Display
          timezone: profileTimezone,
          language_id: profileLanguage,
          theme_id: profileTheme,
          researcher: profileLanguage,

          //Demographics -background
          gender_id: profileGender,
          date_of_birth: profileDOB,
          primary_language_id: profileHomeLanguage,
          country: profileHomeCountry,
          home_state_id: profileHomeState,

          //Demographics - school
          school_id: profileSchool,
          cip_code_id: profileCipCode,
          started_school: profileStartedSchool,

          //Demographics - impairments
          impairment_visual: profileImpVisual,
          impairment_auditory: profileImpAuditory,
          impairment_cognitive: profileImpCognitive,
          impairment_motor: profileImpMotor,
          impairment_other: profileImpOther
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
        console.log(data);

        if (data.messages != null && Object.keys(data.messages).length < 2) {
          const profile = data.user;

          setProfileFields(profile);

          setShowErrors(true);
          setDirty(false);
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
      statusActions.startTask();
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      statusActions.endTask("loading");
      getProfile();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  useEffect(() => setDirty(true), [
    profileFirstName,
    profileLastName,
    profileTimezone,
    profileTheme,
    profileResearcher,
    profileLanguage,
    //Demographics
    profileGender,
    profileCipCode,
    profileSchool,
    profileHomeCountry,
    profileHomeState,
    profileDOB,
    profileHomeLanguage,
    profileStartedSchool,
    profileImpAuditory,
    profileImpCognitive,
    profileImpMotor,
    profileImpVisual,
    profileImpOther
  ]);

  useEffect(() => getStates(profileHomeCountry), [profileHomeCountry]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveProfile}>
      {null == profileId ? "Create" : "Save"} Profile
    </Button>
  ) : null;

  const detailsComponent = (
    <Paper>
      <Accordion expanded>
        <AccordionSummary id="profile">
          Edit your profile
        </AccordionSummary>
        <AccordionDetails>
          <Grid container spacing={3}>
            <Grid item sm={6} xs={12}>
              <TextField
                label="First Name"
                id="first-name"
                value={profileFirstName}
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
                value={profileLastName}
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
              {0 < profileEmails.length ? (
                <UserEmailList
                  token={props.token}
                  emailList={profileEmails}
                  emailListUpdateFunc={setProfileEmails}
                  addMessagesFunc={setMessages}
                  addEmailUrl={addEmailUrl}
                  removeEmailUrl={removeEmailUrl}
                  primaryEmailUrl={primaryEmailUrl}
                />
              ) : null}
            </Grid>
            <Grid item xs={12}>
              <Link href={passwordResetUrl}>
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
                  value={profileTheme}
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
                  value={profileLanguage}
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
                    checked={profileResearcher}
                    onChange={event =>
                      setProfileResearcher(!Boolean(event.target.value))
                    }
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
                  value={profileTimezone}
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
        <AccordionSummary
          expandIcon={<ExpandMoreIcon />}
          id="demographics"
        >
          Tell us about yourself, {profileFirstName} (optional)
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
                  value={profileSchool}
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
                  value={profileCipCode}
                  onChange={event =>
                    setProfileCipCode(Number(event.target.value))
                  }
                >
                  <MenuItem value={0}>None Selected</MenuItem>
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
              <LocalizationProvider dateAdapter={LuxonUtils}>
                <DatePicker
                  clearable
                  value={profileStartedSchool}
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
                  value={profileHomeCountry}
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
                    value={profileHomeState}
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
                  value={profileHomeLanguage}
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
                  value={profileGender}
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
              <LocalizationProvider dateAdapter={LuxonUtils}>
                <DatePicker
                  clearable
                  value={profileDOB}
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
                  selected={profileImpVisual}
                  onClick={() => {
                    setProfileImpVisual(!profileImpVisual);
                  }}
                >
                  Visual
                </ToggleButton>
                <ToggleButton
                  value="auditory"
                  selected={profileImpAuditory}
                  onClick={() => {
                    setProfileImpAuditory(!profileImpAuditory);
                  }}
                >
                  Auditory
                </ToggleButton>
                <ToggleButton
                  value="cognitive"
                  selected={profileImpCognitive}
                  onClick={() => {
                    setProfileImpCognitive(!profileImpCognitive);
                  }}
                >
                  Cognitive
                </ToggleButton>
                <ToggleButton
                  value="motor"
                  selected={profileImpMotor}
                  onClick={() => {
                    setProfileImpMotor(!profileImpMotor);
                  }}
                >
                  Motor
                </ToggleButton>
                <ToggleButton
                  value="other"
                  selected={profileImpOther}
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
      <Tabs
        centered
        value={curTab}
        onChange={(event, value) => setCurTab(value)}
      >
        <Tab label="Details" value="details" />
        <Tab label="My Courses" value="courses" />
        <Tab label="History" value="history" />
        <Tab label="Research Participation" value="research" />
      </Tabs>
      {"details" === curTab ? detailsComponent : null}
      {"courses" === curTab ? (
        <UserCourseList
          token={props.token}
          retrievalUrl={coursePerformanceUrl + ".json"}
          coursesList={courses}
          coursesListUpdateFunc={setCourses}
          addMessagesFunc={setMessages}
        />
      ) : null}
      {"history" === curTab ? (
        <UserActivityList
          token={props.token}
          retrievalUrl={activitiesUrl + ".json"}
          activitiesList={activities}
          activitiesListUpdateFunc={setActivities}
          addMessagesFunc={setMessages}
        />
      ) : null}
      {"research" === curTab ? (
        <ResearchParticipationList
          token={props.token}
          retrievalUrl={consentFormsUrl + ".json"}
          consentFormList={consentForms}
          consentFormListUpdateFunc={setConsentForms}
          addMessagesFunc={setMessages}
        />
      ) : null}
    </Paper>
  );
}

ProfileDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  profileId: PropTypes.number
};
