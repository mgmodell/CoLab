import React, { useState, useEffect } from "react";
import axios from "axios";

import UserEmailList from "./UserEmailList";
const UserCourseList = React.lazy(() => import("./UserCourseList"));
const ResearchParticipationList = React.lazy(() =>
  import("./ResearchParticipationList")
);
const UserActivityList = React.lazy(() => import("./UserActivityList"));
//import i18n from './i18n';
import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import { useTypedSelector } from "../infrastructure/AppReducers";
import {
  fetchProfile,
  setProfile,
  persistProfile,
  setLocalLanguage
} from "../infrastructure/ProfileSlice";

import { Button } from "primereact/button";
import { Accordion, AccordionTab } from "primereact/accordion";
import { Skeleton } from "primereact/skeleton";
import { TabPanel, TabView } from "primereact/tabview";
import { Panel } from "primereact/panel";
import { Calendar } from "primereact/calendar";
import { Dropdown } from "primereact/dropdown";
import { InputSwitch } from "primereact/inputswitch";
import { InputText } from "primereact/inputtext";
import { SelectButton } from "primereact/selectbutton";
import { Container, Row, Col } from "react-grid-system";

type Props = {
  // profileId: number;
};

const impairmentOptions = [
  { label: "Visual", value: "visual" },
  { label: "Auditory", value: "auditory" },
  { label: "Motor", value: "motor" },
  { label: "Cognitive", value: "cognitive" },
  { label: "Other", value: "other" }
];

export default function ProfileDataAdmin(props: Props) {
  const category = "profile";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const { t } = useTranslation(`${category}s`);
  const lookupStatus = useTypedSelector(
    state => state.context.status.lookupsLoaded
  );
  const user = useTypedSelector(state => state.profile.user);

  const getImpairments = () => {
    const imp = [];
    if (user.impairment_visual) {
      imp.push("visual");
    }
    if (user.impairment_auditory) {
      imp.push("auditory");
    }
    if (user.impairment_motor) {
      imp.push("motor");
    }
    if (user.impairment_cognitive) {
      imp.push("cognitive");
    }
    if (user.impairment_other) {
      imp.push("other");
    }
    return imp;
  };

  const setProfileImpairment = (imp : string[]) => {
    setProfileImpVisual(imp.includes("visual"));
    setProfileImpAuditory(imp.includes("auditory"));
    setProfileImpMotor(imp.includes("motor"));
    setProfileImpCognitive(imp.includes("cognitive"));
    setProfileImpOther(imp.includes("other"));
  };

  
  const lastRetrieved = useTypedSelector(state => state.profile.lastRetrieved);
  const [initRetrieved, setInitRetrieved] = useState(lastRetrieved);

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

  const [curTab, setCurTab] = useState(0);
  const [dirty, setDirty] = useState(false);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const [curPanel, setCurPanel] = useState([0]);

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
    dispatch(fetchProfile())
      .then(setInitRetrieved(lastRetrieved))
      .then(setDirty(false));
  };
  const saveProfile = () => {
    dispatch(persistProfile());
    setDirty(false);
  };

  useEffect(() => {
    if (endpointStatus) {
      dispatch(endTask("loading"));
      getProfile();
    }
  }, [endpointStatus]);

  useEffect(() => {
    //TODO: Fix profiles are marked dirty on initial load.
    if (initRetrieved !== lastRetrieved) {
      setDirty(true);
    }
  }, [user]);

  useEffect(() => getStates(user.country), [user.country]);

  const saveButton = (
    <Button onClick={saveProfile} disabled={!dirty}>
      {null == user.id ? "Create" : "Save"} Profile
    </Button>
  );

  const detailsComponent = lookupStatus ? (
    <Panel>
      <Accordion multiple activeIndex={curPanel}>
        <AccordionTab header={t("edit_profile")} aria-label={t("edit_profile")}>
          <Container>
            <Row>
            <Col sm={6} xs={12}>
              <span className="p-float-label">
              <InputText
                id='first-name'
                itemID="first-name"
                name="first-name"
                value={user.first_name}
                onChange={event => setProfileFirstName(event.target.value)}
                />
                <label htmlFor="first-name">{t("first_name")}</label>
              </span>
            </Col>
            <Col sm={6} xs={12}>
              <span className="p-float-label">
                <InputText
                  id='last-name'
                  itemID="last-name"
                  name="last-name"
                  value={user.last_name}
                  onChange={event => setProfileLastName(event.target.value)}
                  />
                  <label htmlFor="last-name">{t("last_name")}</label>
              </span>
            </Col>
            </Row>
            <Row>

            </Row>
          </Container>
        </AccordionTab>
        <AccordionTab
          header={t("email_settings")}
          aria-label={t("email_settings")}
        >
          <Container>
            <Col xs={12}>
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
            </Col>
            <Col xs={12}>
              <a href={endpoints["passwordResetUrl"]}>{t("password_change")}</a>
            </Col>
          </Container>
        </AccordionTab>
        <AccordionTab
          header={t("display_settings.prompt")}
          aria-label={t("display_settings.prompt")}
        >
          <Container>
            <Col md={6} xs={12}>
              <span className="p-float-label">
                <Dropdown
                  id='profile_theme'
                  inputId="profile_theme"
                  itemID="profile_theme"
                  name="profile_theme"
                  value={user.theme_id || 0}
                  options={themes}
                  optionValue="id"
                  optionLabel="name"
                  onChange={event => setProfileTheme(Number(event.value))}
                  placeholder={t("display_settings.ui_theme")}
                />
                <label htmlFor="profile_theme">{t("display_settings.ui_theme")}</label>
              </span>
            </Col>
            <Col md={6} xs={12}>
              <span className="p-float-label">
                <Dropdown
                  id='profile_language'
                  inputId="profile_language"
                  itemID="profile_language"
                  name="profile_language"
                  value={user.language_id || 0}
                  options={languages}
                  optionValue="id"
                  optionLabel="name"
                  onChange={event => setProfileLanguage(Number(event.value))}
                  placeholder={t("display_settings.language")}
                />
                <label htmlFor="profile_language">{t("display_settings.language")}</label>
              </span>
            </Col>
            <Col xs={3}>
              <InputSwitch
                checked={user.researcher}
                onChange={event => setProfileResearcher(!profileResearcher)}
                name="researcher"
              />
              <label htmlFor="researcher">{t("display_settings.anonymize")}</label>
            </Col>
            <Col xs={9}>
              <span className="p-float-label">
                <Dropdown
                  id='profile_timezone'
                  inputId="profile_timezone"
                  itemID="profile_timezone"
                  name="profile_timezone"
                  value={user.timezone || 0}
                  options={timezones}
                  optionValue="name"
                  optionLabel="name"
                  onChange={event => setProfileTimezone(String(event.value))}
                  placeholder={t("display_settings.time_zone")}
                />
                <label htmlFor="profile_timezone">{t("display_settings.time_zone")}</label>
              </span>
            </Col>
          </Container>
        </AccordionTab>
        <AccordionTab
          header={t("demographics.prompt", { first_name: user.first_name })}
          aria-label={t("demographics.prompt", { first_name: user.first_name })}
        >
          <Container>
            <Col xs={12} sm={6}>
              <span className="p-float-label">
                <Dropdown
                  id='profile_school'
                  inputId="profile_school"
                  itemID="profile_school"
                  name="profile_school"
                  value={user.school_id || 0}
                  options={schools}
                  optionValue="id"
                  optionLabel="name"
                  onChange={event => setProfileSchool(Number(event.value))}
                  placeholder={t("demographics.school")}
                />
                <label htmlFor="profile_school">{t("demographics.school")}</label>
              </span>
            </Col>
            <Col xs={12} sm={6}>
              <span className="p-float-label">
                <Dropdown
                  id='profile_cip_code'
                  inputId="profile_cip_code"
                  itemID="profile_cip_code"
                  name="profile_cip_code"
                  value={user.cip_code_id || 0}
                  options={cipCodes}
                  optionValue="id"
                  optionLabel="name"
                  onChange={event => setProfileCipCode(Number(event.value))}
                  placeholder={t("demographics.major")}
                />
                <label htmlFor="profile_cip_code">{t("demographics.major")}</label>
              </span>
            </Col>
            <Col xs={12} sm={6}>
              <span className="p-float-label">
              <Calendar
                id="profile_primary_start_school"
                inputId="profile_primary_start_school"
                name="profile_primary_start_school"
                value={
                  user.started_school
                }
                onChange={date => setProfileStartedSchool(date)}
                dateFormat="mm/dd/yy"
                showIcon={true}
                showTime={false}
                monthNavigator={true}
                yearNavigator={true}
                showButtonBar={true}
                />
                <label htmlFor="profile_primary_start_school">
                  {t('demographics.start_school')}
                </label>
                </span>
            </Col>
            <Col xs={12} md={6}>
              <span className="p-float-label">
                <Dropdown
                  id='profile_country'
                  inputId="profile_country"
                  itemID="profile_country"
                  name="profile_country"
                  value={user.country || 0}
                  options={countries}
                  optionValue="code"
                  optionLabel="name"
                  onChange={event => {
                    const country = String(event.value);
                    setProfileHomeCountry(country);
                  }}
                  placeholder={t("demographics.home_town")}
                />
                <label htmlFor="profile_country">{t("demographics.home_town")}</label>
              </span>
            </Col>
            <Col xs={12} md={6}>
              {states.length > 0 ? (
                <span className="p-float-label">
                  <Dropdown
                    id='profile_state'
                    inputId="profile_state"
                    itemID="profile_state"
                    name="profile_state"
                    value={user.home_state_id || 0}
                    options={states}
                    optionValue="id"
                    optionLabel="name"
                    onChange={event => {
                      setProfileHomeState(Number(event.value));
                    }}
                    placeholder={t("demographics.home_state")}
                  />
                  <label htmlFor="profile_state">{t("demographics.home_state")}</label>
                </span>
              ) : null}
            </Col>
            <Col xs={12} md={6}>
              <span className="p-float-label">
                <Dropdown
                  id='profile_language'
                  inputId="profile_language"
                  itemID="profile_language"
                  name="profile_language"
                  value={user.primary_language_id || 0}
                  options={languages}
                  optionValue="id"
                  optionLabel="name"
                  onChange={event => setProfileHomeLanguage(Number(event.value))}
                  placeholder={t("demographics.home_language")}
                />
                <label htmlFor="profile_language">{t("demographics.home_language")}</label>
              </span>
            </Col>
            <Col xs={12} sm={6}>
              <span className="p-float-label">
                <Dropdown
                  id='profile_gender'
                  name="profile_gender"
                  itemID="profile_gender"
                  value={user.gender_id || 0}
                  onChange={event => setProfileGender(Number(event.value))}
                  options={genders }
                  optionLabel="name"
                  optionValue="id"
                  placeholder={t('demographics.gender')}
                  />
                  <label htmlFor="profile_gender">{t('demographics.gender')}</label>
                  </span>
            </Col>
            <Col xs={12} sm={6} md={3}>
              <span className="p-float-label">
                  <label htmlFor="profile_date_of_birth">
                    {t('demographics.boen')}
                  </label>
                <Calendar
                  id="profile_date_of_birth"
                  value={
                    user.date_of_birth
                  }
                  onChange={date => setProfileDOB(date)}
                  dateFormat="mm/dd/yy"
                  showIcon={true}
                  showTime={false}
                  monthNavigator={true}
                  yearNavigator={true}
                  showButtonBar={true}
                  />
              </span>
            </Col>
            <Col xs={12} md={12}>
              <label htmlFor="impairments">
                {t("demographics.impairments.prompt")}
              </label>
              <SelectButton
                id="impairments"
                name="impairments"
                aria-label="impairments"
                value={getImpairments()}
                onChange={event => setProfileImpairment(event.target.value)}
                multiple={true}
                />
            </Col>
          </Container>
        </AccordionTab>
      </Accordion>
      &nbsp;
      <br />
      <br />
      {saveButton}
    </Panel>
  ) : null;

  return (
    <Panel>
      <TabView
        activeIndex={curTab}
        onTabChange={event => setCurTab(event.index)}
      >
        <TabPanel header={"Details"} disabled={!profileReady}>
          {profileReady ? (
            detailsComponent
          ) : (
            <Skeleton className="mb-2" height="10rem" width="100%" />
          )}
        </TabPanel>
        <TabPanel header={"My Courses"} disabled={!existingProfile}>
          <UserCourseList
            retrievalUrl={endpoints["coursePerformanceUrl"] + ".json"}
            coursesList={courses}
            coursesListUpdateFunc={setCourses}
            addMessagesFunc={setMessages}
          />
        </TabPanel>
        <TabPanel header={"History"} disabled={!existingProfile}>
          <UserActivityList
            retrievalUrl={endpoints["activitiesUrl"] + ".json"}
            activitiesList={activities}
            activitiesListUpdateFunc={setActivities}
            addMessagesFunc={setMessages}
          />
        </TabPanel>
        <TabPanel header={"Research Participation"} disabled={!existingProfile}>
          <ResearchParticipationList
            retrievalUrl={endpoints["consentFormsUrl"] + ".json"}
            consentFormList={consentForms}
            consentFormListUpdateFunc={setConsentForms}
            addMessagesFunc={setMessages}
          />
        </TabPanel>
      </TabView>
    </Panel>
  );
}
