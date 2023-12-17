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

import TextField from "@mui/material/TextField";
import Paper from "@mui/material/Paper";
import Typography from "@mui/material/Typography";
import FormHelperText from "@mui/material/FormHelperText";
import FormControl from "@mui/material/FormControl";
import Select from "@mui/material/Select";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import Link from "@mui/material/Link";
import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";
import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";

import { StudentData, UserListType } from "./CourseUsersList";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { iconForType } from "../ActivityLib";

import { DateTime, Settings } from "luxon";
const CourseUsersList = React.lazy(() => import("./CourseUsersList"));
import { useTranslation } from "react-i18next";
import CourseAdminListToolbar from "./CourseAdminListToolbar";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";
import { Button } from "primereact/button";
import { TabView } from "primereact/tabview";
import { TabPanel } from "primereact/tabview";
import { Skeleton } from "primereact/skeleton";

export default function CourseDataAdmin(props) {
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
  const user = useTypedSelector(state => state.profile.user);
  const tz_hash = useTypedSelector(
    state => state.context.lookups.timezone_lookup
  );

  const navigate = useNavigate();

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
  const [courseStartDate, setCourseStartDate] = useState(DateTime.local());
  //Using this Luxon function for later i18n
  const [courseEndDate, setCourseEndDate] = useState(
    DateTime.local().plus({ month: 3 })
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
  const [newActivityLinks, setNewActivityLinks] = useState([]);
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

        let receivedDate = DateTime.fromISO(course.start_date).setZone(
          Settings.timezone
        );
        setCourseStartDate(receivedDate);
        receivedDate = DateTime.fromISO(course.end_date).setZone(
          Settings.timezone
        );

        setCourseEndDate(receivedDate);
        setCourseRegImage(course.reg_link);
        course.activities.forEach(activity => {
          receivedDate = DateTime.fromISO(activity.end_date).setZone(
            Settings.timezone
          );
          activity.end_date = receivedDate;
          receivedDate = DateTime.fromISO(activity.start_date).setZone(
            Settings.timezone
          );
          activity.start_date = receivedDate;
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

          var receivedDate = DateTime.fromISO(data.course.start_date).setZone(
            tz_hash[courseTimezone]
          );

          setCourseStartDate(receivedDate);

          receivedDate = DateTime.fromISO(data.course.end_date).setZone(
            tz_hash[courseTimezone]
          );
          setCourseEndDate(receivedDate);

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
    <Paper>
      <TextField
        label="Course Number"
        id="course-number"
        value={courseNumber}
        fullWidth={false}
        onChange={event => setCourseNumber(event.target.value)}
        error={Boolean(messages["number"])}
        helperText={messages["number"]}
      />
      <TextField
        label="Course Name"
        id="course-name"
        value={courseName}
        fullWidth={false}
        onChange={event => setCourseName(event.target.value)}
        error={Boolean(messages["name"])}
        helperText={messages["name"]}
      />
      <br />
      <TextField
        label="Course Description"
        id="course-description"
        value={courseDescription}
        fullWidth={true}
        multiline={true}
        onChange={event => setCourseDescription(event.target.value)}
        error={Boolean(messages["description"])}
        helperText={messages["description"]}
      />
      <br />
      <br />
      <FormControl>
        <InputLabel htmlFor="course_school" id="course_school_lbl">
          School
        </InputLabel>
        {schools.length > 0 ? (
          <Select
            id="course_school"
            value={courseSchoolId}
            onChange={event => {
              const changeTo = Number(event.target.value);
              setCourseSchoolId(changeTo);
              setCourseTimezone(schoolTzHash[changeTo]);
            }}
          >
            <MenuItem value={0}>None Selected</MenuItem>
            {schools.map(school => {
              return (
                <MenuItem key={"school_" + school.id} value={school.id}>
                  {school.name}
                </MenuItem>
              );
            })}
          </Select>
        ) : (
          <Skeleton className={"mb-2"} height={'2rem'} />
        )}
        <FormHelperText>Error schtuff</FormHelperText>
      </FormControl>

      <FormControl>
        <InputLabel htmlFor="course_timezone" id="course_timezone_lbl">
          Time Zone
        </InputLabel>
        {timezones.length > 0 ? (
          <Select
            id="course_timezone"
            value={courseTimezone}
            onChange={event => setCourseTimezone(String(event.target.value))}
          >
            {timezones.map(timezone => {
              return (
                <MenuItem key={timezone.name} value={timezone.name}>
                  {timezone.name}
                </MenuItem>
              );
            })}
          </Select>
        ) : (
          <Skeleton className={"mb-2"} height={'2rem'} />
        )}
        <FormHelperText>More Error Schtuff</FormHelperText>
      </FormControl>

      <FormControl>
        <InputLabel htmlFor="course_consent_form" id="course_consent_form_lbl">
          Consent Form
        </InputLabel>
        <Select
          id="course_consent_form"
          value={courseConsentFormId}
          onChange={event => setCourseConsentFormId(Number(event.target.value))}
        >
          <MenuItem value={0}>None Selected</MenuItem>
          {consentForms.map(consent_form => {
            return (
              <MenuItem key={consent_form.id} value={consent_form.id}>
                {consent_form.name}
              </MenuItem>
            );
          })}
        </Select>
        <FormHelperText>More Error Schtuff</FormHelperText>
      </FormControl>

      <Typography>All dates shown in {courseTimezone} timezone.</Typography>
      <LocalizationProvider dateAdapter={AdapterLuxon} adapterLocale="en-us">
        <DatePicker
          autoOk={true}
          inputFormat="MM/dd/yyyy"
          margin="normal"
          label="Course Start Date"
          value={courseStartDate}
          onChange={setCourseStartDate}
          error={Boolean(messages["start_date"])}
          helperText={messages["start_date"]}
          slot={{
            TextField: TextField
          }}
          slotProps={{
            textField: {
              id: "course_start_date"
            }
          }}
        //renderInput={props => <TextField id="course_start_date" {...props} />}
        />
        {Boolean(messages["start_date"]) ? (
          <FormHelperText error={true}>{messages["start_date"]}</FormHelperText>
        ) : null}

        <DatePicker
          autoOk={true}
          inputFormat="MM/dd/yyyy"
          margin="normal"
          label="Course End Date"
          //value={courseEndDate}
          onChange={setCourseEndDate}
          error={Boolean(messages["end_date"])}
          helperText={messages["end_date"]}
          slot={{
            TextField: TextField
          }}
          slotProps={{
            textField: {
              id: "course_end_date"
            }
          }}

        //renderInput={props => <TextField id="course_end_date" {...props} />}
        />
      </LocalizationProvider>
      {Boolean(messages["end_date"]) ? (
        <FormHelperText error={true}>{messages["end_date"]}</FormHelperText>
      ) : null}
      <br />
      {courseId != null && courseId > 0 ? (
        <Link href={courseRegImage}>
          <img src={courseRegImage} alt="Registration QR Code" />
          Download self-registration code
        </Link>
      ) : null}

      <br />
    </Paper>
  );

  enum ACTIVITY_COLS {
    STATUS = "status",
    OPEN = "open",
    CLOSE = "close",
  }

  const optColumns = [
    ACTIVITY_COLS.STATUS,
    ACTIVITY_COLS.OPEN,
    ACTIVITY_COLS.CLOSE,
  ]


  const activityList =
    courseId != null && courseId > 0 ? (
      <>
        <DataTable
          value={courseActivities.filter((activity) => {

            //Add filtering here
            return filterText.length === 0 || activity.name.includes(filterText);

          })}
          resizableColumns
          reorderableColumns
          paginator
          rows={5}
          tableStyle={{
            minWidth: '50rem'
          }}
          rowsPerPageOptions={
            [5, 10, 20, courseActivities.length]
          }
          header={
            <CourseAdminListToolbar
              newActivityLinks={newActivityLinks}
              filtering={{
                filterValue: filterText,
                setFilterFunc: setFilterText,
              }}
              columnToggle={{
                optColumns: optColumns,
                visibleColumns: optActivityColumns,
                setVisibleColumnsFunc: setOptActivityColumns,

              }}
            />}
          sortOrder={-1}
          paginatorDropdownAppendTo={'self'}
          paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
          onRowClick={(event) => {
            const link = event.data.link; //courseActivities[cellMeta.dataIndex].link;
            const activityId = event.data.id; // courseActivities[cellMeta.dataIndex].id;
            navigate(`${link}/${activityId}`);
          }}
          currentPageReportTemplate="{first} to {last} of {totalRecords}"
          dataKey="id"
        >
          <Column
            header={t('activities.type_col')}
            field="type"
            body={(rowData) => {
              return iconForType(rowData.type);
            }}
          />
          <Column
            header={t('activities.name_col')}
            field="name"
          />
          {optActivityColumns.includes(ACTIVITY_COLS.STATUS) ? (
          <Column
            header={t('activities.status_col')}
            field="status"
            body={(rowData) => {
              if (!rowData.active) {
                return 'Not Activated'
              }
              else if (rowData.end_date > DateTime.local()) {
                return "Active";
              } else {
                return "Expired";
              }
            }}
          /> ): null
            }
            {optActivityColumns.includes(ACTIVITY_COLS.OPEN) ? (
          <Column
            header={t('activities.open_col')}
            field="start_date"
            body={(rowData) => {
              const dt = DateTime.fromISO(rowData.start_date);
              return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
            }}
          />
              ):null }
              {optActivityColumns.includes(ACTIVITY_COLS.CLOSE) ? (
          <Column
            header={t('activities.close_col')}
            field="end_date"
            body={(rowData) => {
              const dt = DateTime.fromISO(rowData.end_date);
              return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;

            }}
          />
                ): null}
          <Column
            header=''
            field="link"
            body={(rowData) => {
              const lbl = t('activities.delete_lbl');
              return (
                <Button
                  icon="pi pi-trash"
                  aria-label="Delete"
                  tooltip={lbl}
                  onClick={event => {
                    dispatch(startTask("deleting"));
                    axios
                      // Is this right? Shouldn't it be params.value?
                      .delete(user.drop_link, {})
                      .then(response => {
                        const data = response.data;
                        getCourse();
                        setMessages(data.messages);
                        dispatch(endTask("deleting"));
                      })
                      .catch(error => {
                        console.log("error:", error);
                      }).finally(() => {
                        dispatch(endTask("deleting"));
                      })
                  }}
                />
              );
            }}
          />

        </DataTable>
      </>

    ) : (
      <div>{t('activities.save_first_msg')}</div>
    );

  return (
    <Paper>
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
    </Paper>
  );
}
