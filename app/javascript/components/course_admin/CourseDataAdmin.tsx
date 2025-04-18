import React, { useState, useEffect } from "react";
import axios from "axios";
import { Outlet, Route, Routes, useNavigate, useParams } from "react-router";
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
import { FloatLabel } from "primereact/floatlabel";
import ActivityList, { Activity } from "./ActivityList";
import CourseWizard from "./wizard/CourseWizard";
import { utcAdjustDate, utcAdjustEndDate } from "../infrastructure/Utilities";
import {DateTime} from 'luxon';

interface IActivityLink {
  name: string;
  link: string;
}

interface ICourse {
  id: number;
  name: string;
  number: string;
  description: string;
  start_date: Date;
  end_date: Date;
  school_id: number;
  consent_form_id: number;
  timezone: string;
  reg_link: string;
  activities: Array<Activity>;
};


export default function CourseDataAdmin() {
  const category = "course";
  const { t } = useTranslation(`${category}s`);

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

  const [course, setCourse] = useState<ICourse>({
    id: courseId,
    name: "",
    number: "",
    description: "",
    start_date: new Date(),
    end_date: new Date(),
    school_id: null,
    consent_form_id: null,
    timezone: "UTC",
    reg_link: "",
    activities: []
  });

  const [courseUsersList, setCourseUsersList] = useState(Array<StudentData>);

  //Using this Luxon function for later i18n

  const schools = useTypedSelector(state => state.context.lookups["schools"]);
  const timezones = useTypedSelector(
    state => state.context.lookups["timezones"]
  );
  const [consentForms, setConsentForms] = useState([]);
  const [newActivityLinks, setNewActivityLinks] = useState<Array<IActivityLink>>([]);
  const [schoolTzHash, setSchoolTzHash] = useState({});

  const dispatch = useDispatch();
  const navigate = useNavigate();

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

        const localCourse: ICourse = {
          id: courseId,
          name: course.name || "",
          number: course.number || '',
          description: course.description || '',
          start_date: new Date(Date.parse(course.start_date)),
          end_date: new Date(Date.parse(course.end_date)),
          school_id: course.school_id,
          consent_form_id: course.consent_form_id,
          timezone: course.timezone || "UTC",
          reg_link: course.reg_link,
          activities: course.activities
        }
        setCourse(localCourse);

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
          course_id: courseId,
          name: course.name,
          number: course.number,
          description: course.description,
          start_date: course.start_date,
          end_date: course.end_date,
          school_id: course.school_id,
          consent_form_id: course.consent_form_id,
          timezone: course.timezone
        }
      }
    })
      .then(response => {
        const data = response.data;

        if (Object.keys(data.messages).length < 2) {
          const timezoneAdjust = data.course.timezone
          const timezone = timezones.find(tz => tz.name === timezoneAdjust);
          const procStartDate = DateTime.fromISO(data.course.start_date, { zone: timezone.stdName });
          const procEndDate = DateTime.fromISO(data.course.end_date, { zone: timezone.stdName });


          const localCourse: ICourse = Object.assign({},
            data.course,
            {
              start_date: procStartDate.plus( {minutes: procStartDate.offset }).toJSDate( ),
              end_date: procEndDate.plus( {minutes: procEndDate.offset }).toJSDate( ),
            }
          );
          setCourse(localCourse);
          setCourseId(localCourse.id);
          navigate(`../${localCourse.id}`, { replace: true });


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
    course,
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

  const setCourseValue = (field, value) => {
    setCourse(course => {
      return { ...course, [field]: value };
    });
  }

  const detailsComponent = (
    <Panel>
      <label htmlFor="course-number" id="course-number_lbl">
        {t('edit.number')}
      </label>
      <InputText
        placeholder="Course Number"
        id="course-number"
        value={course.number}
        onChange={event => {
          setCourseValue('number', event.target.value);
        }}
      />
      {Boolean(messages['course_number']) ? (
        <Message severity="error" text={messages['course_number']} />
      ) : null}
      <br />
      <label htmlFor="course-name" id="course-name_lbl">
        {t('edit.name')}
      </label>
      <InputText
        placeholder="Course Name"
        id="course-name"
        value={course.name}
        onChange={event => {
          setCourseValue('name', event.target.value);
        }}
      />
      {Boolean(messages['course_name']) ? (
        <Message severity="error" text={messages['course_name']} />
      ) : null}
      <br />
      <label htmlFor="course-description" id="course-description_lbl">
        {t('edit.description')}
      </label>
      <InputTextarea
        placeholder="Course Description"
        id="course-description"
        value={course.description}
        onChange={event => {
          setCourseValue('description', event.target.value);
        }}
        rows={5}
        cols={30}
        autoResize={true}
      />
      {Boolean(messages['course_description']) ? (
        <Message severity="error" text={messages['course_description']} />
      ) : null}
      <br />
      <label htmlFor="course_school" id="course_school_lbl">
        {t('edit.school')}
      </label>
      {schools.length > 0 ? (
        <Dropdown
          id="course_school"
          value={course.school_id}
          options={schools}
          onChange={event => {
            const changeTo = Number(event.target.value);
            setCourse(course => {
              return {
                ...course,
                school_id: changeTo,
                timezone: schoolTzHash[changeTo]
              };
            });
          }}
          optionLabel="name"
          optionValue="id"
          placeholder="Select a School"
          showClear={false}
        />
      ) : (
        <Skeleton className={"mb-2"} height={'2rem'} />
      )}

      <label htmlFor="course_timezone" id="course_timezone_lbl">
        {t('edit.time_zone')}
      </label>
      {timezones.length > 0 ? (
        <Dropdown id="course_timezone"
          value={course.timezone}
          options={timezones}
          onChange={event => {
            setCourseValue('timezone', event.target.value);
          }}
          optionLabel="name"
          optionValue="name"
          placeholder="Select a Time Zone"
          showClear={false}
        />
      ) : (
        <Skeleton className={"mb-2"} height={'2rem'} />
      )}

      <label htmlFor="course_consent_form" id="course_consent_form_lbl">
        {t('edit.consent')}
      </label>
      <Dropdown
        id="course_consent_form"
        value={course.consent_form_id}
        options={consentForms}
        onChange={event => {
          setCourseValue('consent_form_id', event.target.value);
        }}
        optionValue="id"
        optionLabel="name"
        placeholder="Select a Consent Form"
        showClear={true}
      />

      <p>{t('edit.dates_tz', { time_zone: course.timezone })}</p>
      <label htmlFor="course_dates" id="course_dates_lbl">
        {t('edit.dates')}
      </label>
      <FloatLabel>
        <Calendar
          id="course_start_date"
          inputId="course_start_date"
          value={utcAdjustDate(course.start_date)}
          onChange={event => {
            const changeTo = event.value;
            if (null !== changeTo) {
              setCourseValue('start_date', changeTo);
            }
          }}
          showOnFocus={false}
          showIcon={true}
        />
        <label htmlFor="course_start_date">{t('start_date_lbl')}</label>
      </FloatLabel>
      {Boolean(messages["start_date"]) ? (
        <Message severity="error" text={messages["start_date"]} />
      ) : null}
      {t('date_to_lbl')}
      <FloatLabel>
        <Calendar
          id="course_end_date"
          inputId="course_end_date"
          value={utcAdjustEndDate(course.end_date)}
          onChange={event => {
            const changeTo = event.value;
            setCourseValue('end_date', changeTo);
          }}
          showOnFocus={false}
          showIcon={true}
        />
        <label htmlFor="course_end_date">{t('end_date_lbl')}</label>
      </FloatLabel>

      {Boolean(messages["end_date"]) ? (
        <Message severity="error" text={messages["end_date"]} />
      ) : null}
      <br />
      {courseId != null && courseId > 0 ? (
        <a href={course.reg_link} download>
          <img src={course.reg_link} alt="Registration QR Code" />
          {t('edit.download_qr')}
        </a>
      ) : null}

      <br />
    </Panel>
  );



  const activityList =
    courseId != null && courseId > 0 ? (
      <ActivityList
        activities={course.activities}
        newActivityLinks={newActivityLinks}
        refreshFunc={getCourse}
      />

    ) : (
      <div>{t('activities.save_first_msg')}</div>
    );

  const advancedCourseAdmin = (
    <Panel>
      <TabView
        activeIndex={curTab}
        onTabChange={(event) => setCurTab(event.index)}
      >

        <TabPanel header={t("details_tab")}>{detailsComponent}</TabPanel>
        <TabPanel header={t("instructors_tab")} disabled={isNaN(courseId)}>
          <CourseUsersList
            courseId={courseId}
            retrievalUrl={endpoints.courseUsersUrl + courseId + ".json"}
            usersList={courseUsersList}
            usersListUpdateFunc={setCourseUsersList}
            userType={UserListType.instructor}
            addMessagesFunc={postNewMessage}
          />
        </TabPanel>
        <TabPanel header={t("students_tab")} disabled={isNaN(courseId)}>
          <CourseUsersList
            courseId={courseId}
            retrievalUrl={endpoints.courseUsersUrl + courseId + ".json"}
            usersList={courseUsersList}
            usersListUpdateFunc={setCourseUsersList}
            userType={UserListType.student}
            addMessagesFunc={postNewMessage}
          />
        </TabPanel>
        <TabPanel header={t("activities_tab")} disabled={isNaN(courseId)}>
          {activityList}
        </TabPanel>
      </TabView>
      <Button
        label={t('wizard.wizard_switch')}
        onClick={() => {
          navigate('courseWizard');
        }}
      />
      {saveButton}
      {messages["status"]}
    </Panel>

  )
  return (
    <Routes>
      <Route path="/" element={<Outlet />}>
        <Route
          index
          element={
            advancedCourseAdmin
          }
        />
        <Route
          path={'courseWizard'}
          element={
            <CourseWizard
              course={course}
              setCourseFunc={setCourse}
              saveCourseFunc={saveCourse}
            />
          }
        />

      </Route>


    </Routes>
  );
}

export { ICourse, IActivityLink }