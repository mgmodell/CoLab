import React, { useState, useEffect } from "react";
import axios from "axios";
import { useParams, useNavigate } from "react-router-dom";
//Redux store stuff
import { useDispatch } from "react-redux";
import {
  startTask,
  endTask,
  setDirty,
  setClean,
  addMessage,
  Priorities
} from "../infrastructure/StatusSlice";


import { StudentData, UserListType } from "./CourseUsersList";
import { useTypedSelector } from "../infrastructure/AppReducers";

const CourseUsersList = React.lazy(() => import("./CourseUsersList"));
import { useTranslation } from "react-i18next";
import { Button } from "primereact/button";
import { TabView } from "primereact/tabview";
import { TabPanel } from "primereact/tabview";
import { Skeleton } from "primereact/skeleton";
import { Dropdown } from "primereact/dropdown";
import { Panel } from "primereact/panel";
import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";
import { Message } from "primereact/message";
import { Calendar } from "primereact/calendar";
import ActivityList from "./ActivityList";

interface IActivityLink {
  name: string;
  link: string;
}

export default function CourseDataAdmin() {
  const category = "course";
  const { t } = useTranslation(`${category}s`);
  const [filterText, setFilterText] = useState('');
  const [optActivityColumns, setOptActivityColumns] = useState([]);

  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const [curTab, setCurTab] = useState(0);
  const dirty = useTypedSelector(state => {
    return state.status.dirtyStatus[category];
  });
  const [messages, setMessages] = useState({});

  let { courseIdParam } = useParams();

  const [courseId, setCourseId] = useState(
    parseInt("new" === courseIdParam ? null : courseIdParam)
  );

  const [courseName, setCourseName] = useState("");
  const [courseNumber, setCourseNumber] = useState("");
  const [courseDescription, setCourseDescription] = useState("");
  const [courseUsersList, setCourseUsersList] = useState(Array<StudentData>);
  const [courseActivities, setCourseActivities] = useState([]);
  

  const [courseStartDate, setCourseStartDate] = useState(new Date);
  //Using this Luxon function for later i18n
  const [courseEndDate, setCourseEndDate] = useState(
    new Date( ( new Date ).setMonth ((new Date ).getMonth() + 3 ) )
  );

  const [courseSchoolId, setCourseSchoolId] = useState(0);
  const [courseTimezone, setCourseTimezone] = useState("");
  const [courseConsentFormId, setCourseConsentFormId] = useState(0);
  const [courseRegImage, setCourseRegImage] = useState(null);

  const schools = useTypedSelector(state => state.context.lookups["schools"]);
  const timezones = useTypedSelector(
    state => state.context.lookups["timezones"]
  );
  const [consentForms, setConsentForms] = useState([]);
  const [newActivityLinks, setNewActivityLinks] =  useState <Array<IActivityLink>>([]);
  const [schoolTzHash, setSchoolTzHash] = useState({});

  const dispatch = useDispatch();

  const getCourse = () => {
    dispatch(startTask());
    dispatch(setDirty(category));

    const url = isNaN(courseId)
      ? `${endpoints.baseUrl}/new.json`
      : `${endpoints.baseUrl}/${courseId}.json`;

    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        //setSchools(data.schools);
        setConsentForms(data.consent_forms);
        setNewActivityLinks(data.new_activity_links);

        const course = data.course;

        setCourseName(course.name || "");
        setCourseNumber(course.number || "");
        setCourseDescription(course.description || "");

        setCourseStartDate(new Date( Date.parse(course.start_date) ));
        setCourseEndDate(new Date( Date.parse(course.end_date) ));

        setCourseRegImage(course.reg_link);
        course.activities.forEach(activity => {

          activity.end_date = new Date( Date.parse(activity.end_date) );
          activity.start_date = new Date( Date.parse(activity.start_date) );
        });
        setCourseActivities(course.activities);
        setCourseTimezone(course.timezone || "UTC");
        setCourseConsentFormId(course.consent_form_id || 0);
        setCourseSchoolId(course.school_id || 0);

        dispatch(setClean(category));
        
      })
      .catch(error => {
        console.log("error:", error);
      }).finally(() => {
        dispatch(endTask("loading"));
      })
  };

  const saveCourse = () => {
    const method = isNaN(courseId) ? "POST" : "PATCH";
    dispatch(startTask("saving"));

    const url = isNaN(courseId)
      ? `${endpoints.baseUrl}/new.json`
      : `${endpoints.baseUrl}/${courseId}.json`;

    axios({
      method: method,
      url: url,
      data: {
        course: {
          name: courseName,
          number: courseNumber,
          course_id: courseId,
          description: courseDescription,
          start_date: courseStartDate,
          end_date: courseEndDate,
          school_id: courseSchoolId,
          consent_form_id: courseConsentFormId,
          timezone: courseTimezone
        }
      }
    })
      .then(response => {
        const data = response.data;
        if (Object.keys(data.messages).length < 2) {
          setCourseId(data.course.id);
          setCourseName(data.course.name);
          setCourseNumber(data.course.number);
          setCourseDescription(data.course.description);
          setCourseTimezone(data.course.timezone);
          setCourseConsentFormId(data.course.consent_form_id || 0);
          setCourseSchoolId(data.course.school_id);

          setCourseStartDate(new Date( Date.parse(data.course.start_date) ));

          setCourseEndDate(new Date( Date.parse(data.course.end_date) ));

          dispatch(setClean(category));
        }
        postNewMessage(data.messages);
      })
      .catch(error => {
        console.log("error:", error);
        dispatch(endTask("saving"));
      }).finally(() => {
        dispatch(endTask("saving"));
      })
  };

  useEffect(() => {
    if (schools.length > 0) {
      const newSchoolTzHash = Object.assign({}, schoolTzHash);
      schools.map(schoolData => {
        newSchoolTzHash[schoolData.id] = schoolData.timezone;
      });
      setSchoolTzHash(newSchoolTzHash);
    }
  }, [schools]);

  useEffect(() => {
    if (endpointStatus) {
      dispatch(endTask("loading"));
      getCourse();
    }
  }, [endpointStatus]);

  useEffect(() => {
    dispatch(setDirty(category));
  }, [
    courseName,
    courseDescription,
    courseTimezone,
    courseSchoolId,
    courseConsentFormId,
    courseStartDate,
    courseEndDate
  ]);

  const postNewMessage = msgs => {
    dispatch(addMessage(msgs.main, new Date(), Priorities.INFO));
    setMessages(msgs);
  };

  const saveButton = dirty ? (
    <React.Fragment>
      <hr />
      <Button onClick={saveCourse}>
        {Boolean(courseId) ? "Save" : "Create"} Course
      </Button>
    </React.Fragment>
  ) : null;

  const detailsComponent = (
    <Panel>
        <label htmlFor="course-number" id="course-number_lbl">
          Course Number
        </label>
      <InputText
        placeholder="Course Number"
        id="course-number"
        value={courseNumber}
        onChange={event => setCourseNumber(event.target.value)}
        />
        {Boolean(messages['course_number']) ? (
          <Message severity="error" text={messages['course_number']} />
        ) : null}
        <br />
        <label htmlFor="course-name" id="course-name_lbl">
          Course Name
          </label>
          <InputText
          placeholder="Course Name"
          id="course-name"
          value={courseName}
          onChange={event => setCourseName(event.target.value)}
        />
        {Boolean(messages['course_name']) ? (
          <Message severity="error" text={messages['course_name']} />
        ) : null}
        <br />
        <label htmlFor="course-description" id="course-description_lbl">
          Course Description
        </label>
        <InputTextarea
        placeholder="Course Description"
        id="course-description"
        value={courseDescription}
        onChange={event => setCourseDescription(event.target.value)}
        rows={5}
        cols={30}
        autoResize={true}
        />
        {Boolean(messages['course_description']) ? (
          <Message severity="error" text={messages['course_description']} />
        ) : null}
        <br />
        <label htmlFor="course_school" id="course_school_lbl">
          School
        </label>
        {schools.length > 0 ? (
          <Dropdown
            id="course_school"
            value={courseSchoolId}
            options={schools}
            onChange={event => {
              const changeTo = Number(event.target.value);
              setCourseSchoolId(changeTo);
              setCourseTimezone(schoolTzHash[changeTo]);
            }}
            optionLabel="name"
            optionValue="id"
            placeholder="Select a School"
            showClear={true}
            />
        ) : (
          <Skeleton className={"mb-2"} height={'2rem'} />
        )}

        <label htmlFor="course_timezone" id="course_timezone_lbl">
          Time Zone
        </label>
        {timezones.length > 0 ? (
          <Dropdown id="course_timezone"
            value={courseTimezone}
            options={timezones}
            onChange={event => setCourseTimezone(String(event.target.value))}
            optionLabel="name"
            optionValue="name"
            placeholder="Select a Time Zone"
            showClear={true}
            />
        ) : (
          <Skeleton className={"mb-2"} height={'2rem'} />
        )}

        <label htmlFor="course_consent_form" id="course_consent_form_lbl">
          Consent Form
        </label>
        <Dropdown
          id="course_consent_form"
          value={courseConsentFormId}
          options={consentForms}
          onChange={event => setCourseConsentFormId(Number(event.target.value))}
          optionValue="id"
          optionLabel="name"
          placeholder="Select a Consent Form"
          showClear={true}
          />

      <p>All dates shown in {courseTimezone} timezone.</p>
        <label htmlFor="course_dates" id="course_dates_lbl">
          Course Dates
        </label>
      <Calendar
        id="course_dates"
        selectionMode={'range'}
        value={[courseStartDate, courseEndDate]}
        placeholder="Select a Date Range"
        onChange={event => {
          setCourseStartDate(event.value[0]);
          setCourseEndDate(event.value[1]);
        }}

        />
        {Boolean(messages["start_date"]) ? (
          <Message severity="error" text={messages["start_date"]} />
        ) : null}

      {Boolean(messages["end_date"]) ? (
        <Message severity="error" text={messages["end_date"]} />
      ) : null}
      <br />
      {courseId != null && courseId > 0 ? (
        <a href={courseRegImage} download>
          <img src={courseRegImage} alt="Registration QR Code" />
          Download self-registration code
        </a>
      ) : null}

      <br />
    </Panel>
  );



  const activityList =
    courseId != null && courseId > 0 ? (
      <ActivityList
        activities={courseActivities}
        newActivityLinks={newActivityLinks}
        refreshFunc={getCourse}
        />

    ) : (
      <div>{t('activities.save_first_msg')}</div>
    );

  return (
    <Panel>
      <TabView
        activeIndex={curTab}
        onTabChange={(event) => setCurTab(event.index)}
      >

        <TabPanel header={t("details_tab")}>{detailsComponent}</TabPanel>
        <TabPanel header={t("instructors_tab")}>
          <CourseUsersList
            courseId={courseId}
            retrievalUrl={endpoints.courseUsersUrl + courseId + ".json"}
            usersList={courseUsersList}
            usersListUpdateFunc={setCourseUsersList}
            userType={UserListType.instructor}
            addMessagesFunc={postNewMessage}
          />
        </TabPanel>
        <TabPanel header={t("students_tab")}>
          <CourseUsersList
            courseId={courseId}
            retrievalUrl={endpoints.courseUsersUrl + courseId + ".json"}
            usersList={courseUsersList}
            usersListUpdateFunc={setCourseUsersList}
            userType={UserListType.student}
            addMessagesFunc={postNewMessage}
          />
        </TabPanel>
        <TabPanel header={t("activities_tab")}>{activityList}</TabPanel>
      </TabView>
      {saveButton}
      {messages["status"]}
    </Panel>
  );
}

export { IActivityLink}