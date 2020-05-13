import React, { useState, useEffect } from "react";
import Alert from "@material-ui/lab/Alert";
import Button from "@material-ui/core/Button";
import Collapse from "@material-ui/core/Collapse";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import TextField from "@material-ui/core/TextField";
import Paper from "@material-ui/core/Paper";
import Tab from "@material-ui/core/Tab";
import Tabs from "@material-ui/core/Tabs";
import Typography from "@material-ui/core/Typography";
import FormHelperText from "@material-ui/core/FormHelperText";
import FormControl from "@material-ui/core/FormControl";
import Select from "@material-ui/core/Select";
import InputLabel from "@material-ui/core/InputLabel";
import MenuItem from "@material-ui/core/MenuItem";
import Menu from "@material-ui/core/Menu";
import Tooltip from "@material-ui/core/Tooltip";

import {iconForType} from './ActivityLib'

import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from "@material-ui/pickers";

import { DateTime, Info } from "luxon";
import Settings from "luxon/src/settings.js";
import { useUserStore } from "./UserStore";
import CourseUsersList from "./CourseUsersList";

import LuxonUtils from "@date-io/luxon";
import { useEndpointStore } from "./EndPointStore";
import MUIDataTable from "mui-datatables";

import AddIcon from "@material-ui/icons/Add";
import CloseIcon from "@material-ui/icons/Close";
import DeleteForeverIcon from "@material-ui/icons/DeleteForever";
import IconButton from "@material-ui/core/IconButton";
import Link from "@material-ui/core/Link";

export default function CourseDataAdmin(props) {
  const endpointSet = "course";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();

  const [curTab, setCurTab] = useState("details");
  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);
  const [courseId, setCourseId] = useState(props.courseId);
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
  const [courseSchoolId, setCourseSchoolId] = useState<number>(0);
  const [courseTimezone, setCourseTimezone] = useState("");
  const [courseConsentFormId, setCourseConsentFormId] = useState(0);
  const [courseRegImage, setCourseRegImage] = useState(null);

  const [schools, setSchools] = useState([]);
  const [timezones, setTimezones] = useState([]);
  const [consentForms, setConsentForms] = useState([]);
  const [newActivityLinks, setNewActivityLinks] = useState([]);
  const [schoolTzHash, setSchoolTzHash] = useState({});

  const getCourse = () => {
    setDirty(true);
    var url = endpoints.endpoints[endpointSet].baseUrl + "/";
    if (null == courseId) {
      url = url + "new.json";
    } else {
      url = url + courseId + ".json";
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
        //MetaData and Infrastructure
        setTimezones(data.timezones);
        setSchools(data.schools);
        data.schools.map(schoolData => {
          schoolTzHash[schoolData.id] = schoolData.timezone;
        });
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

        setWorking(false);
        setDirty(false);
      });
  };
  const saveCourse = () => {
    const method = null == courseId ? "POST" : "PATCH";
    setWorking(true);

    const url =
      endpoints.endpoints[endpointSet].baseUrl +
      "/" +
      (Boolean(courseId) ? courseId : props.courseId) +
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
        course: {
          name: courseName,
          number: courseNumber,
          course_id: props.courseId,
          description: courseDescription,
          start_date: courseStartDate,
          end_date: courseEndDate,
          school_id: courseSchoolId,
          consent_form_id: courseConsentFormId,
          timezone: courseTimezone
        }
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        console.log(data.messages);
        console.log(data);
        console.log(Object.keys(data.messages).length);
        if (Object.keys(data.messages).length < 2) {
          setCourseId(data.id);
          setCourseName(data.name);
          setCourseNumber(data.number);
          setCourseDescription(data.description);
          setCourseTimezone(data.timezone);
          setCourseConsentFormId(data.consent_form_id);
          setCourseSchoolId(data.school_id);

          var receivedDate = DateTime.fromISO(data.start_date).setZone(
            courseTimezone
          );
          setCourseStartDate(receivedDate);

          receivedDate = DateTime.fromISO(data.end_date).setZone(
            courseTimezone
          );
          setCourseEndDate(receivedDate);

          setWorking(false);
          setDirty(false);
        }
        postNewMessage(data.messages);
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      getCourse();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  useEffect(() => {
    if (user.loaded) {
      Settings.defaultZoneName = user.timezone;
    }
  }, [user.loaded]);

  useEffect(() => setDirty(true), [
    courseName,
    courseDescription,
    courseTimezone,
    courseSchoolId,
    courseConsentFormId,
    courseStartDate,
    courseEndDate
  ]);

  const postNewMessage = msgs => {
    setMessages(msgs);
    setShowErrors(true);
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
        <FormHelperText>Error schtuff</FormHelperText>
      </FormControl>

      <FormControl>
        <InputLabel htmlFor="course_timezone" id="course_timezone_lbl">
          Time Zone
        </InputLabel>
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
      <MuiPickersUtilsProvider utils={LuxonUtils}>
        <KeyboardDatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          format="MM/dd/yyyy"
          margin="normal"
          id="course_start_date"
          label="Course Start Date"
          value={courseStartDate}
          onChange={setCourseStartDate}
          error={Boolean(messages["start_date"])}
          helperText={messages["start_date"]}
        />
      </MuiPickersUtilsProvider>
      {Boolean(messages["start_date"]) ? (
        <FormHelperText error={true}>{messages["start_date"]}</FormHelperText>
      ) : null}

      <MuiPickersUtilsProvider utils={LuxonUtils}>
        <KeyboardDatePicker
          disableToolbar
          variant="inline"
          autoOk={true}
          format="MM/dd/yyyy"
          margin="normal"
          id="course_end_date"
          label="Course End Date"
          value={courseEndDate}
          onChange={setCourseEndDate}
          error={Boolean(messages["end_date"])}
          helperText={messages["end_date"]}
        />
      </MuiPickersUtilsProvider>
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
          const dt = DateTime.fromISO(value, {
            zone: Settings.defaultZoneName
          });
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
          const dt = DateTime.fromISO(value, {
            zone: Settings.defaultZoneName
          });
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
                  fetch(user.drop_link, {
                    method: "DESTROY",
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
                      getCourse();
                      setMessages(data.messages);
                      setWorking(false);
                    });
                }}
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
                window.location.href = linkData.link;
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
          responsive: "scrollMaxHeight",
          filterType: "checkbox",
          print: false,
          download: false,
          customToolbar: () => {
            return addButton;
          },
          onCellClick: (colData, cellMeta) => {
            console.log(cellMeta);
            if ("link" != activityColumns[cellMeta.colIndex].name) {
              const link = courseActivities[cellMeta.rowIndex].link;
              if (null != link) {
                window.location.href = link;
              }
            }
          }
        }}
      />
    ) : (
      "You must save the Course to have activities."
    );

  return (
    <Paper>
      <Collapse in={showErrors}>
        <Alert
          action={
            <IconButton
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
        <Tab value="instructors" label="Instructors" />
        <Tab value="students" label="Students" />
        <Tab value="activities" label="Activities" />
      </Tabs>
      {working ? <LinearProgress /> : null}
      {"details" == curTab ? detailsComponent : null}
      {"instructors" == curTab ? (
        <CourseUsersList
          token={props.token}
          courseId={courseId}
          retrievalUrl={
            endpoints.endpoints[endpointSet].courseUsersUrl + courseId + ".json"
          }
          usersList={courseUsersList}
          usersListUpdateFunc={setCourseUsersList}
          userType="instructor"
          working={working}
          setWorking={setWorking}
          addMessagesFunc={postNewMessage}
        />
      ) : null}
      {"students" == curTab ? (
        <CourseUsersList
          token={props.token}
          courseId={courseId}
          retrievalUrl={
            endpoints.endpoints[endpointSet].courseUsersUrl + courseId + ".json"
          }
          usersList={courseUsersList}
          usersListUpdateFunc={setCourseUsersList}
          userType="student"
          working={working}
          setWorking={setWorking}
          addMessagesFunc={postNewMessage}
        />
      ) : null}
      {"activities" == curTab ? activityList : null}
      {saveButton}
      {messages["status"]}
    </Paper>
  );
}

CourseDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  courseId: PropTypes.number
};
