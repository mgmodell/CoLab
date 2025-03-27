import React, { useState, useEffect, useMemo } from "react";
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
  setLocalLanguage,
  IUser
} from "../infrastructure/ProfileSlice";
import { utcAdjust } from "../infrastructure/Utilities";

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
import { AutoComplete } from "primereact/autocomplete";
import { ColorPicker } from "primereact/colorpicker";

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
  const user: IUser = useTypedSelector(state => state.profile.user);

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

  const setProfileImpairment = (imp: string[]) => {
    const temp = {};
    Object.assign(temp, user);

    temp['impairment_visual'] = imp.includes("visual");
    temp['impairment_auditory'] = imp.includes("auditory");
    temp['impairment_motor'] = imp.includes("motor");
    temp['impairment_cognitive'] = imp.includes("cognitive");
    temp['impairment_other'] = imp.includes("other");

    dispatch(setProfile(temp));
  };

  const lastRetrieved = useTypedSelector(state => state.profile.lastRetrieved);
  const dirty = useTypedSelector(state => {
    return state.profile.lastRetrieved !== state.profile.lastSet;
  });
  const [initRetrieved, setInitRetrieved] = useState(lastRetrieved);

  const profileReady = endpointStatus && lookupStatus;
  const existingProfile = profileReady && undefined != user && user.id > 0;

  const timezones = useTypedSelector(state => state.context.lookups.timezones);
  const countries = useTypedSelector(state => state.context.lookups.countries);
  const cipCodes = useTypedSelector(state => state.context.lookups.cip_codes);
  const genders = useTypedSelector(state => state.context.lookups.genders);
  const schools = useTypedSelector(state => state.context.lookups.schools);
  const languages = useTypedSelector(state => state.context.lookups.languages);

  const [states, setStates] = useState([]);

  const [courses, setCourses] = useState();

  const [activities, setActivities] = useState();

  const [consentForms, setConsentForms] = useState();

  //const { t, i18n } = useTranslation('profiles' );
  const dispatch = useDispatch();

  const [curTab, setCurTab] = useState(0);
  const [curPanel, setCurPanel] = useState([0]);

  const setMessages = msgs => {
    Object.keys(msgs).forEach(key => {
      if ("main" === key) {
        dispatch(addMessage(msgs[key], new Date(), Priorities.INFO));
      } else {
        dispatch(addMessage(msgs[key], new Date(), Priorities.WARNING));
      }
    });
  };

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
    temp.gender_id = gender;
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

    temp.date_of_birth = date_of_birth.toString();
    dispatch(setProfile(temp));
  };
  const setProfileStartedSchool = started_school => {
    const temp = {};
    Object.assign(temp, user);
    temp.started_school = started_school.toString();
    dispatch(setProfile(temp));
  };

  //Display
  const setProfileLanguage = language_id => {
    dispatch(setLocalLanguage(language_id));
  };
  const setProfileTheme = theme => {
    const temp = {};
    Object.assign(temp, user);
    temp.theme = theme;
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

  useEffect(() => getStates(user.country), [user.country]);

  //Support for AutoComplete
  const [localProfileLanguage, setLocalProfileLanguage] = useState(
    languages.find(lang => lang.id === user.language_id).name
  );
  const [
    suggestedLocalProfileLanguages,
    setSuggestedLocalProfileLanguages
  ] = useState(languages);

  const [localHomeLanguage, setLocalHomeLanguage] = useState(
    null === user.primary_language_id
      ? languages[0]
      : languages.find(lang => lang.id === user.primary_language_id).name
  );
  const [
    suggestedLocalHomeLanguages,
    setSuggestedLocalHomeLanguages
  ] = useState(languages);

  const saveButton = (
    <Button onClick={saveProfile} disabled={!dirty}>
      {null == user.id ? "Create" : "Save"} Profile
    </Button>
  );

  const emailPanel = useMemo(() => {
    return(
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
    )
  }, [user.emails]);

  const detailsComponent = lookupStatus ? (
    <Panel>
      <Accordion multiple
        onTabChange={event => setCurPanel([0,...(event.index.filter( i => i !== 0 ))])}
        activeIndex={[...curPanel]}
        >
        <AccordionTab
          key='edit_profile'
          header={t("edit_profile")}
          aria-label={t("edit_profile")}
          className="fixedDrawer"
          >
          <Container>
            <Row>
              <Col sm={6} xs={12}>
                <span className="p-float-label">
                  <InputText
                    id="first-name"
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
                    id="last-name"
                    itemID="last-name"
                    name="last-name"
                    value={user.last_name}
                    onChange={event => setProfileLastName(event.target.value)}
                  />
                  <label htmlFor="last-name">{t("last_name")}</label>
                </span>
              </Col>
            </Row>
          </Container>
        </AccordionTab>
        <AccordionTab
          key='email_settings'
          header={t("email_settings")}
          aria-label={t("email_settings")}
        >
          {emailPanel}
        </AccordionTab>
        <AccordionTab
          key='display_settings'
          header={t("display_settings.prompt")}
          aria-label={t("display_settings.prompt")}
        >
          <Container>
            <Col md={6} xs={12}>
                <label htmlFor="profile_theme">
                  {t("display_settings.ui_theme")}
                </label>
                <ColorPicker
                  id='profile_theme'
                  value={user.theme}
                  onChange={event => setProfileTheme(event.value)} />
            </Col>
            <Col md={6} xs={12}>
              <span className="p-float-label">
                <AutoComplete
                  id="profile_language"
                  inputId="profile_language"
                  itemID="profile_language"
                  name="profile_language"
                  value={localProfileLanguage}
                  suggestions={Object.values( suggestedLocalProfileLanguages )}
                  field="name"
                  forceSelection={true}
                  dropdown

                  completeMethod={event => {
                    const query = event.query.toLocaleLowerCase();
                    setSuggestedLocalProfileLanguages(
                      languages.filter(lang =>
                        ['en','ko', 'es'].includes(lang.code) &&
                        lang.name.toLowerCase().includes(query)
                      )
                    );
                  }}
                  onChange={event => {
                    if (typeof event.value === "string") {
                      setLocalProfileLanguage(event.value);
                    }
                  }}
                  onSelect={event => {
                    setLocalProfileLanguage(event.value.name);
                    setProfileLanguage(event.value.id);
                  }}
                  placeholder={t("display_settings.language")}
                />
                <label htmlFor="profile_language">
                  {t("display_settings.language")}
                </label>
              </span>
            </Col>
            <Col xs={3}>
              <InputSwitch
                checked={user.researcher}
                onChange={event => setProfileResearcher(!profileResearcher)}
                name="researcher"
              />
              <label htmlFor="researcher">
                {t("display_settings.anonymize")}
              </label>
            </Col>
            <Col xs={9}>
              <span className="p-float-label">
                <Dropdown
                  id="profile_timezone"
                  inputId="profile_timezone"
                  itemID="profile_timezone"
                  name="profile_timezone"
                  value={user.timezone || 0}
                  options={Object.values( timezones )}
                  optionValue="name"
                  optionLabel="name"
                  onChange={event => setProfileTimezone(String(event.value))}
                  placeholder={t("display_settings.time_zone")}
                />
                <label htmlFor="profile_timezone">
                  {t("display_settings.time_zone")}
                </label>
              </span>
            </Col>
          </Container>
        </AccordionTab>
        <AccordionTab
          key='demographics'
          header={t("demographics.prompt", { first_name: user.first_name })}
          aria-label={t("demographics.prompt", { first_name: user.first_name })}
        >
          <Container>
            <Row>
              <Col xs={12} sm={6}>
                <span className="p-float-label">
                  <Dropdown
                    id="profile_school"
                    inputId="profile_school"
                    itemID="profile_school"
                    name="profile_school"
                    value={user.school_id || 0}
                    options={Object.values( schools )}
                    optionValue="id"
                    optionLabel="name"
                    onChange={event => setProfileSchool(Number(event.value))}
                    placeholder={t("demographics.school")}
                  />
                  <label htmlFor="profile_school">
                    {t("demographics.school")}
                  </label>
                </span>
              </Col>
              <Col xs={12} sm={6}>
                <span className="p-float-label">
                  <Dropdown
                    id="profile_cip_code"
                    inputId="profile_cip_code"
                    itemID="profile_cip_code"
                    name="profile_cip_code"
                    value={user.cip_code_id || 0}
                    options={Object.values( cipCodes )}
                    optionValue="id"
                    optionLabel="name"
                    onChange={event => setProfileCipCode(Number(event.value))}
                    placeholder={t("demographics.major")}
                  />
                  <label htmlFor="profile_cip_code">
                    {t("demographics.major")}
                  </label>
                </span>
              </Col>
              <Col xs={12} sm={6}>
                <span className="p-float-label">
                  <Calendar
                    id="profile_primary_start_school"
                    inputId="profile_primary_start_school"
                    name="profile_primary_start_school"
                    value={utcAdjust(user.started_school)}
                    onChange={date => setProfileStartedSchool(date.value)}
                    dateFormat="mm/dd/yy"
                    showIcon={true}
                    showOnFocus={false}
                    monthNavigator={true}
                    showButtonBar={true}
                  />
                  <label htmlFor="profile_primary_start_school">
                    {t("demographics.start_school")}
                  </label>
                </span>
              </Col>
            </Row>
            <Row>
              <Col xs={12}>
                <h5>{t("demographics.home_town")}</h5>
              </Col>
            </Row>
            <Row>
              <Col xs={6} md={5}>
                <span className="p-float-label">
                  <Dropdown
                    id="profile_country"
                    inputId="profile_country"
                    itemID="profile_country"
                    name="profile_country"
                    value={user.country || 0}
                    options={ Object.values( countries )}
                    optionValue="code"
                    optionLabel="name"
                    onChange={event => {
                      const country = String(event.value);
                      setProfileHomeCountry(country);
                    }}
                    placeholder={t("demographics.home_country")}
                  />
                  <label htmlFor="profile_country">
                    {t("demographics.home_country")}
                  </label>
                </span>
              </Col>
              <Col xs={6}>
                {states.length > 0 ? (
                  <span className="p-float-label">
                    <Dropdown
                      id="profile_state"
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
                    <label htmlFor="profile_state">
                      {t("demographics.home_state")}
                    </label>
                  </span>
                ) : null}
              </Col>
            </Row>
            <Row>
              <Col xs={12}>
                <span className="p-float-label">
                  <AutoComplete
                    id="profile_home_language"
                    inputId="profile_home_language"
                    itemID="profile_home_language"
                    name="profile_home_language"
                    value={localHomeLanguage}
                    suggestions={Object.values( suggestedLocalHomeLanguages )}
                    field="name"
                    forceSelection={true}
                    dropdown
                    completeMethod={event => {
                      const query = event.query.toLocaleLowerCase();
                      setSuggestedLocalHomeLanguages(
                        languages.filter(lang =>
                          lang.name.toLowerCase().includes(query)
                        )
                      );
                    }}
                    onChange={event => {
                      if (typeof event.value === "string") {
                        setLocalHomeLanguage(event.value);
                      }
                    }}
                    onSelect={event => {
                      setLocalHomeLanguage(event.value.name);
                      setProfileHomeLanguage(event.value.id);
                    }}
                    placeholder={t("demographics.home_language")}
                  />
                  <label htmlFor="profile_home_language">
                    {t("demographics.home_language")}
                  </label>
                </span>
              </Col>
              <Col xs={12} sm={6}>
                <span className="p-float-label">
                  <Dropdown
                    id="profile_gender"
                    name="profile_gender"
                    itemID="profile_gender"
                    value={user.gender_id || 0}
                    onChange={event => setProfileGender(Number(event.value))}
                    options={Object.values( genders )}
                    optionLabel="name"
                    optionValue="id"
                    placeholder={t("demographics.gender")}
                  />
                  <label htmlFor="profile_gender">
                    {t("demographics.gender")}
                  </label>
                </span>
              </Col>
              <Col xs={12} sm={6} md={3}>
                <span className="p-float-label">
                  <Calendar
                    id="profile_date_of_birth"
                    inputId="profile_date_of_birth"
                    name="profile_date_of_birth"
                    value={utcAdjust(user.date_of_birth)}
                    onChange={date => setProfileDOB(date.value)}
                    dateFormat="mm/dd/yy"
                    showIcon={true}
                    monthNavigator={true}
                    showOnFocus={false}
                    showButtonBar={true}
                  />
                  <label htmlFor="profile_date_of_birth">
                    {t("demographics.born")}
                  </label>
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
                  options={impairmentOptions}
                  onChange={event => {
                    setProfileImpairment(event.target.value)
                    event.originalEvent.currentTarget.blur( )
                  }}
                  multiple
                />
              </Col>
            </Row>
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
        <TabPanel header={t("tabs.details")} disabled={!profileReady}>
          {profileReady ? (
            detailsComponent
          ) : (
            <Skeleton className="mb-2" height="10rem" width="100%" />
          )}
        </TabPanel>
        <TabPanel header={t("tabs.courses")} disabled={!existingProfile}>
          <UserCourseList
            retrievalUrl={endpoints["coursePerformanceUrl"] + ".json"}
            coursesList={courses}
            coursesListUpdateFunc={setCourses}
            addMessagesFunc={setMessages}
          />
        </TabPanel>
        <TabPanel header={t("tabs.history")} disabled={!existingProfile}>
          <UserActivityList
            retrievalUrl={endpoints["activitiesUrl"] + ".json"}
            activitiesList={activities}
            activitiesListUpdateFunc={setActivities}
            addMessagesFunc={setMessages}
          />
        </TabPanel>
        <TabPanel header={t("tabs.research")} disabled={!existingProfile}>
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
