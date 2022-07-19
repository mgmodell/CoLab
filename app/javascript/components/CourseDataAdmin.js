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
} from "./infrastructure/StatusActions";
import Button from "@mui/material/Button";
import TextField from "@mui/material/TextField";
import Paper from "@mui/material/Paper";
import Tab from "@mui/material/Tab";
import Typography from "@mui/material/Typography";
import FormHelperText from "@mui/material/FormHelperText";
import FormControl from "@mui/material/FormControl";
import Select from "@mui/material/Select";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import Menu from "@mui/material/Menu";
import Tooltip from "@mui/material/Tooltip";

import { iconForType } from "./ActivityLib";

import { DatePicker, LocalizationProvider } from "@mui/x-date-pickers";
import { TabPanel, TabList, TabContext } from "@mui/lab/";

import { DateTime, Settings } from "luxon";
import CourseUsersList from "./CourseUsersList";

import { AdapterLuxon } from "@mui/x-date-pickers/AdapterLuxon";
import MUIDataTable from "mui-datatables";

import AddIcon from "@mui/icons-material/Add";
import DeleteForeverIcon from "@mui/icons-material/DeleteForever";
import IconButton from "@mui/material/IconButton";
import Link from "@mui/material/Link";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { Box, Skeleton } from "@mui/material";

export default function CourseDataAdmin(props) {
  const category = "course";
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
  const [courseUsersList, setCourseUsersList] = useState();
  const [courseActivities, setCourseActivities] = useState([]);
  const [courseStartDate, setCourseStartDate] = useState(
    DateTime.local().toISO()
  );
  //Using this Luxon function for later i18n
  const [courseEndDate, setCourseEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
      .toISO()
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

        var receivedDate = DateTime.fromISO(course.start_date).setZone(
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
            courseTimezone
          );
          setCourseStartDate(receivedDate);

          receivedDate = DateTime.fromISO(data.course.end_date).setZone(
            courseTimezone
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
      schools.map(schoolData => {
        schoolTzHash[schoolData.id] = schoolData.timezone;
      });
    }
  }, [schools]);

  useEffect(() => {
    if (endpointStatus) {
      dispatch(endTask("loading"));
      getCourse();
    }
  }, [endpointStatus]);

  useEffect(() => {
    if (null !== user.lastRetrieved && null !== tz_hash) {
      Settings.defaultZoneName = tz_hash[user.timezone];
    }
  }, [user.lastRetrieved, tz_hash]);

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
    dispatch(addMessage(msgs.main, Date.now(), Priorities.INFO));
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
      <LocalizationProvider dateAdapter={AdapterLuxon}>
        <DatePicker
          variant="inline"
          autoOk={true}
          inputFormat="MM/dd/yyyy"
          margin="normal"
          label="Course Start Date"
          value={courseStartDate}
          onChange={setCourseStartDate}
          error={Boolean(messages["start_date"])}
          helperText={messages["start_date"]}
          renderInput={props => <TextField id="course_start_date" {...props} />}
        />
      </LocalizationProvider>
      {Boolean(messages["start_date"]) ? (
        <FormHelperText error={true}>{messages["start_date"]}</FormHelperText>
      ) : null}

      <LocalizationProvider dateAdapter={AdapterLuxon}>
        <DatePicker
          variant="inline"
          autoOk={true}
          inputFormat="MM/dd/yyyy"
          margin="normal"
          label="Course End Date"
          value={courseEndDate}
          onChange={setCourseEndDate}
          error={Boolean(messages["end_date"])}
          helperText={messages["end_date"]}
          renderInput={props => <TextField id="course_end_date" {...props} />}
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
  const activityColumns = [
    {
      label: "Type",
      name: "type",
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          return iconForType(value);
        },
        customFilterListOptions: {
          render: value => {
            return iconForType(value);
          }
        },
        filterOptions: {
          names: ["Bingo Games", "Assessments", "Experiences"],
          logic: (location, filters) => {
            switch (location) {
              case "Terms List":
                return filters.includes("Bingo Games");
                break;
              case "Project":
                return filters.includes("Assessments");
                break;
              case "Group Experience":
                return filters.includes("Experiences");
                break;
              default:
                console.log("filter not found: " + location);
            }

            return false;
          }
        }
      }
    },
    {
      label: "Name",
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: "Status",
      name: "end_date",
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          if (value > DateTime.local()) {
            return "Active";
          } else {
            return "Expired";
          }
        }
      }
    },
    {
      label: "Open Date",
      name: "start_date",
      options: {
        filter: false,
        display: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const dt = DateTime.fromISO(value);
          return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
        }
      }
    },
    {
      label: "Close Date",
      name: "end_date",
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const dt = DateTime.fromISO(value);
          return <span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>;
        }
      }
    },
    {
      label: " ",
      name: "link",
      options: {
        filter: false,
        sort: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const lbl = "Delete";
          return (
            <Tooltip title={lbl}>
              <IconButton
                aria-label={lbl}
                onClick={event => {
                  dispatch(startTask("deleting"));

                  axios
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
    }
  ];

  const [menuAnchorEl, setMenuAnchorEl] = useState(null);
  const addButton = (
    <React.Fragment>
      <IconButton
        onClick={event => {
          setMenuAnchorEl(event.currentTarget);
        }}
        aria-label="Add Activity"
        size="large"
      >
        <AddIcon />
      </IconButton>
      <Menu
        id="addMenu"
        anchorEl={menuAnchorEl}
        keepMounted
        open={Boolean(menuAnchorEl)}
        onClose={() => {
          setMenuAnchorEl(null);
        }}
      >
        {newActivityLinks.map(linkData => {
          return (
            <MenuItem
              key={linkData.name}
              onClick={event => {
                setMenuAnchorEl(null);
                navigate(`${linkData.link}/new`);
                // window.location.href = linkData.link;
              }}
            >
              {iconForType(linkData.name)}
              {" New " + linkData.name}&hellip;
            </MenuItem>
          );
        })}
      </Menu>
    </React.Fragment>
  );

  const activityList =
    courseId != null && courseId > 0 ? (
      <MUIDataTable
        title="Activities"
        columns={activityColumns}
        data={courseActivities}
        options={{
          responsive: "standard",
          filterType: "checkbox",
          print: false,
          download: false,
          customToolbar: () => {
            return addButton;
          },
          onCellClick: (colData, cellMeta) => {
            if ("link" != activityColumns[cellMeta.colIndex].name) {
              const link = courseActivities[cellMeta.dataIndex].link;
              const activityId = courseActivities[cellMeta.dataIndex].id;
              navigate(`${link}/${activityId}`);
            }
          }
        }}
      />
    ) : (
      "You must save the Course to have activities."
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
            userType="instructor"
            addMessagesFunc={postNewMessage}
          />
        </TabPanel>
        <TabPanel value="students">
          <CourseUsersList
            courseId={courseId}
            retrievalUrl={endpoints.courseUsersUrl + courseId + ".json"}
            usersList={courseUsersList}
            usersListUpdateFunc={setCourseUsersList}
            userType="student"
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
