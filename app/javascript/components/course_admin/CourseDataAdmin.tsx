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
import Button from "@mui/material/Button";
import Box from "@mui/material/Box";
import TextField from "@mui/material/TextField";
import Paper from "@mui/material/Paper";
import Tab from "@mui/material/Tab";
import Typography from "@mui/material/Typography";
import FormHelperText from "@mui/material/FormHelperText";
import FormControl from "@mui/material/FormControl";
import Select from "@mui/material/Select";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import Skeleton from "@mui/material/Skeleton";
import Tooltip from "@mui/material/Tooltip";
import IconButton from "@mui/material/IconButton";
import Link from "@mui/material/Link";

import { iconForType } from "../ActivityLib";

import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";
import { TabPanel, TabList, TabContext } from "@mui/lab/";

import { DateTime, Settings } from "luxon";
const CourseUsersList = React.lazy(() => import("./CourseUsersList"));

import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";

import DeleteForeverIcon from "@mui/icons-material/DeleteForever";
import { StudentData, UserListType } from "./CourseUsersList";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { DataGrid, GridColDef } from "@mui/x-data-grid";
import { useTranslation } from "react-i18next";
import CourseAdminListToolbar from "../infrastructure/CourseAdminListToolbar";
import { renderTextCellExpand } from "../infrastructure/GridCellExpand";

export default function CourseDataAdmin(props) {
  const category = "course";
  const {t} = useTranslation( `${category}s`);

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

  const [curTab, setCurTab] = useState("details");
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

        dispatch(endTask("loading"));
        dispatch(setClean(category));
      })
      .catch(error => {
        console.log("error:", error);
        dispatch(endTask("loading"));
      });
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
            tz_hash[ courseTimezone]
          );

          setCourseStartDate(receivedDate);

          receivedDate = DateTime.fromISO(data.course.end_date).setZone(
            tz_hash[ courseTimezone ]
          );
          setCourseEndDate(receivedDate);

          dispatch(endTask("saving"));
          dispatch(setClean(category));
        }
        postNewMessage(data.messages);
      })
      .catch(error => {
        console.log("error:", error);
        dispatch(endTask("saving"));
      });
  };

  useEffect(() => {
    if (schools.length > 0) {
      const newSchoolTzHash = Object.assign( {}, schoolTzHash );
      schools.map(schoolData => {
        newSchoolTzHash[schoolData.id] = schoolData.timezone;
      });
      setSchoolTzHash( newSchoolTzHash );
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
      <Button variant="contained" onClick={saveCourse}>
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
          <Skeleton variant="rectangular" height={20} />
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
          <Skeleton variant="rectangular" height={20} />
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
  const activityColumns: GridColDef[] = [
    {
      headerName: t('activities.type_col'),
      field: "type",
      renderCell: (params) => {
          return iconForType(params.row.type);
      }
    },
    {
      headerName: t('activities.name_col'),
      field: "name",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t('activities.status_col'),
      field: "status",
      
      renderCell: (params) => {
          if (params.row.end_date > DateTime.local()) {
            return "Active";
          } else {
            return "Expired";
          }
      }
    },
    {
      headerName: t('activities.open_col'),
      field: "start_date",
      renderCell: (params) => {
        const dt = DateTime.fromISO(params.value);
        return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;

      }
    },
    {
      headerName: t('activities.close_col'),
      field: "end_date",
      renderCell: (params) => {
          const dt = DateTime.fromISO(params.value);
          return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;

      }
    },
    {
      headerName: " ",
      field: "link",
      renderCell: (params) => {
          const lbl = t('activities.delete_lbl');
          return (
            <Tooltip title={lbl}>
              <IconButton
                aria-label={lbl}
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
                      dispatch(endTask("deleting"));
                    });
                }}
                size="large"
              >
                <DeleteForeverIcon />
              </IconButton>
            </Tooltip>
          );
        }
      }
  ];


  const activityList =
    courseId != null && courseId > 0 ? (
      <DataGrid
        columns={activityColumns}
        rows={courseActivities}
        getRowId={(row) => {
          return `${row.type}-${row.id}`;
        }}
        onCellClick={(params)=>{
            if ("link" !== params.colDef.headerName ) {
              const link = params.row.link; //courseActivities[cellMeta.dataIndex].link;
              const activityId = params.row.id; // courseActivities[cellMeta.dataIndex].id;
              navigate(`${link}/${activityId}`);
            }
          }
        }
        slots={{
          toolbar: CourseAdminListToolbar
        }}
        slotProps={{
          toolbar: {
            newActivityLinks: newActivityLinks
          }
        }}
        />

    ) : (
      <div>{t('activities.save_first_msg')}</div>
    );

  return (
    <Paper>
      <TabContext value={curTab}>
        <Box>
          <TabList
            centered
            value={curTab}
            onChange={(event, value) => setCurTab(value)}
          >
            <Tab label="Details" value="details" />
            <Tab value="instructors" label="Instructors" />
            <Tab value="students" label="Students" />
            <Tab value="activities" label="Activities" />
          </TabList>
        </Box>
        <TabPanel value="details">{detailsComponent}</TabPanel>
        <TabPanel value="instructors">
          <CourseUsersList
            courseId={courseId}
            retrievalUrl={endpoints.courseUsersUrl + courseId + ".json"}
            usersList={courseUsersList}
            usersListUpdateFunc={setCourseUsersList}
            userType={UserListType.instructor}
            addMessagesFunc={postNewMessage}
          />
        </TabPanel>
        <TabPanel value="students">
          <CourseUsersList
            courseId={courseId}
            retrievalUrl={endpoints.courseUsersUrl + courseId + ".json"}
            usersList={courseUsersList}
            usersListUpdateFunc={setCourseUsersList}
            userType={UserListType.student}
            addMessagesFunc={postNewMessage}
          />
        </TabPanel>
        <TabPanel value="activities">{activityList}</TabPanel>
      </TabContext>
      {saveButton}
      {messages["status"]}
    </Paper>
  );
}
