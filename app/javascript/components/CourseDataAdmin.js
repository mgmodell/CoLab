import React, { useState, useEffect } from "react";
import Button from "@material-ui/core/Button";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import TextField from "@material-ui/core/TextField";
import Paper from "@material-ui/core/Paper";
import Tab from "@material-ui/core/Tab";
import Tabs from "@material-ui/core/Tabs";
import Typography from "@material-ui/core/Typography";
import FormHelperText from '@material-ui/core/FormHelperText'
import Autocomplete from '@material-ui/lab/Autocomplete';

import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from "@material-ui/pickers";

import { DateTime, Info } from "luxon";
import Settings from 'luxon/src/settings.js'
import { useUserStore } from "./UserStore"


import LuxonUtils from "@date-io/luxon";
import { useEndpointStore } from "./EndPointStore"
import MUIDataTable from "mui-datatables";

import LocalLibraryIcon from '@material-ui/icons/LocalLibrary';
import GridOffIcon from '@material-ui/icons/GridOff';
import TuneIcon from '@material-ui/icons/Tune';
import AddIcon from '@material-ui/icons/Add';
import { IconButton, Menu, MenuItem } from "@material-ui/core";

export default function CourseDataAdmin(props) {

  const endpointSet = 'course';
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();

  const [curTab, setCurTab] = useState("details");
  const [dirty, setDirty] = useState(false);
  const [working, setWorking] = useState(true);
  const [messages, setMessages] = useState({});
  const [courseId, setCourseId] = useState(props.courseId);
  const [courseName, setCourseName] = useState("");
  const [courseNumber, setCourseNumber] = useState("");
  const [courseDescription, setCourseDescription] = useState("");
  const [courseActivities, setCourseActivities ] = useState( [] )
  const [courseStartDate, setCourseStartDate] = useState(
    DateTime.local().toISO( )
  );
  //Using this Luxon function for later i18n
  const [courseEndDate, setCourseEndDate] = useState(
    DateTime.local()
      .plus({ month: 3 })
      .toISO()
  );
  const [courseSchoolId, setCourseSchoolId ] = useState( 0 );
  const [courseTimezone, setCourseTimezone] = useState( 'UTC');
  const [courseConsentFormId, setCourseConsentFormId ] = useState( 0 );

  const [schools, setSchools] = useState( [] );
  const [timezones, setTimezones] = useState( [] );
  const [consentForms, setConsentForms] = useState( [] );
  const [newActivityLinks, setNewActivityLinks ] = useState([])

  const getCourse = () => {
    setDirty(true);
    var url = endpoints.endpoints[endpointSet].baseUrl + "/";
    if (null == courseId) {
      url = url + 'new.json';
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
        console.log( data.timezones );
        setTimezones( data.timezones );
        setSchools( data.schools );
        setConsentForms( data.consent_forms );
        setNewActivityLinks( data.new_activity_links );

        const course = data.course;

        setCourseName(course.name || "");
        setCourseNumber( course.number || '' );
        setCourseDescription(course.description || "");

        var receivedDate = DateTime.fromISO( course.start_date).setZone( Settings.timezone )
        setCourseStartDate(receivedDate );
        receivedDate = DateTime.fromISO( course.end_date).setZone( Settings.timezone )

        setCourseEndDate(receivedDate );
        course.activities.forEach(activity=>{
          receivedDate = DateTime.fromISO( activity.end_date).setZone( Settings.timezone )
          activity.end_date = receivedDate;
          receivedDate = DateTime.fromISO( activity.start_date).setZone( Settings.timezone )
          activity.start_date = receivedDate;

        })
        setCourseActivities( course.activities );
        setCourseTimezone( course.timezone || 'UTC' );
        setCourseConsentFormId( course.consent_form_id || 0 )
        setCourseSchoolId( course.school_id || 0 )


        setWorking(false);
        setDirty(false);
      });
  };
  const saveCourse = () => {
    const method = null == courseId ? "POST" : "PATCH";
    setWorking(true);

    const url =
    endpoints.endpoints[endpointSet].baseUrl + '/' + (null == courseId ? props.courseId : courseId) + ".json";

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
          course_id: props.courseId,
          description: courseDescription,
          start_date: courseStartDate,
          end_date: courseEndDate,
          school_id: courseSchoolId,
          consent_form_id: courseConsentFormId,
          timezone: timezone
        }
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          setMessages(data.messages);
          console.log("error");
        }
      })
      .then(data => {
        if (data.messages != null && Object.keys(data.messages).length < 2) {
          setCourseId( data.id );
          setCourseName(data.name);
          setCourseDescription(data.description);
          setCourseTimezone(data.timezone);
          setCourseConsentFormId(data.consent_form_id);
          setCourseSchoolId(data.school_id);

          var receivedDate = DateTime.fromISO( data.start_date).setZone( courseTimezone )
          setCourseStartDate(receivedDate);

          receivedDate = DateTime.fromISO( data.end_date).setZone( courseTimezone )
          setCourseEndDate(receivedDate);

          setWorking(false);
          setDirty(false);
          setMessages(data.messages);
        } else {
          setMessages(data.messages);
        }
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != 'loaded') {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if( !user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() =>{
    if (endpoints.endpointStatus[endpointSet] == 'loaded') {
      getCourse();
    }
  }, [
    endpoints.endpointStatus[endpointSet]
  ]);

  useEffect(() =>{
    if (user.loaded){
      Settings.defaultZoneName = user.timezone;
    }
  }, [
    user.loaded
  ]);

  useEffect(() => setDirty(true), [
    courseName,
    courseDescription,
    courseTimezone,
    courseSchoolId,
    courseConsentFormId,
    courseStartDate,
    courseEndDate,
  ]);

  const saveButton = dirty ? (
    <Button variant="contained" onClick={saveCourse}>
      {null == courseId ? "Create" : "Save"} Course
    </Button>
  ) : null;

  //Later I want to call the activate/deactivate right here
  const toggleActive = () => {
    setCourseActive(!courseActive);
  };

  const detailsComponent = (
    <Paper>
      {working ? <LinearProgress /> : null}
      <TextField
        label="Course Number"
        id="course-number"
        value={courseNumber}
        fullWidth={false}
        onChange={event => setCourseNumber(event.target.value)}
        error={null != messages.number}
        helperText={messages.number}
      />
      <TextField
        label="Course Name"
        id="course-name"
        value={courseName}
        fullWidth={false}
        onChange={event => setCourseName(event.target.value)}
        error={null != messages.name}
        helperText={messages.name}
      />
      <br/>
      <TextField
        label='Course Description'
        id='course-description'
        value={courseDescription}
        fullWidth={true}
        multiline={true}
        onChange={event => setCourseDescription(event.target.value)}
        error={null != messages.description}
        helperText={messages.description}
      />
      <br/><br/>
      <Autocomplete
        id='course-school'
        options={schools}
        blurOnSelect={true}
        autoComplete={true}
        autoSelect={true}
        onInputChange={(event,value,reason)=>{
          if( 'reset' == reason && 'LI' == event.target.tagName ){
            const lSchool = schools[ event.target.dataset.optionIndex ];
            setCourseSchoolId( lSchool.id );
          }
        }}
        getOptionLabel={option=>option.name}
        renderInput={ params =>
          <TextField
            {...params}
            label='School'
            />

        }
      />
      <Autocomplete
        id='course-timezone'
        options={timezones}
        value={courseTimezone}
        blurOnSelect={true}
        autoComplete={true}
        autoSelect={true}
        onInputChange={(event,value,reason)=>{
          if( 'reset' == reason ){
            //setCourseTimezone( value );
          }
        }}
        renderInput={ params =>
          <TextField
            {...params}
            label='Timezone'
            />

        }
      />
      <Autocomplete
        id='course-consent_form'
        options={consentForms}
        blurOnSelect={true}
        autoComplete={true}
        autoSelect={true}
        onInputChange={(event,value,reason)=>{
          if( 'reset' == reason && 'LI' == event.target.tagName ){
            const lConsentForm = schools[ event.target.dataset.optionIndex ];
            setCourseConsentFormId( lConsentForm.id );
          }
        }}
        getOptionLabel={option=>option.name}
        renderInput={ params =>
          <TextField
            {...params}
            label='Consent Form'
            />

        }
      />

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
          error={null != messages.start_date}
          helperText={messages.start_date}
        />
        </MuiPickersUtilsProvider>
        { null != messages.start_date ? (
          <FormHelperText error={true}>
            {messages.start_date}
          </FormHelperText>
        ): null }

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
          error={null != messages.end_date}
          helperText={messages.end_date}
        />
      </MuiPickersUtilsProvider>
        { null != messages.end_date ? (
          <FormHelperText error={true}>
            {messages.end_date}
          </FormHelperText>
        ): null }
      <br />

      <br />
      {saveButton}
      {messages.status}
    </Paper>
  );
  const iconForType = (type)=>{
    var icon
    if( ['Group Experience','Experiences'].includes( type )){
      icon = <LocalLibraryIcon/>
    }else if( ['Project','Assessments'].includes( type ) ){
      icon = <TuneIcon/>
    }else if( ['Terms List','Bingo Games'].includes( type ) ){
      icon = <GridOffIcon/>
    }else{
      console.log( type );
    }
    return(icon)
  }
  const activityColumns = 
  [
    {
      label: 'Type',
      name: 'type',
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          return iconForType( value );
        },
        customFilterListOptions: { 
          render: value =>{
            return iconForType( value );
          }
        },
        filterOptions: {
          names: ['Bingo Games', 'Assessments', 'Experiences'],
          logic: (location, filters) => {
            switch( location ) {
              case 'Terms List':
                return filters.includes( 'Bingo Games' );
                break;
              case 'Project':
                return filters.includes( 'Assessments' );
                break
              case 'Group Experience':
                return filters.includes( 'Experiences' );
                break;
              default:
                console.log( 'filter not found: ' + location)
            }

            return( false )

          }
        }
      }
    },
    {
      label: 'Name',
      name: 'name',
      options: {
        filter: false
      }
    },
    {
      label: 'Status',
      name: 'end_date',
      options: {
        customBodyRender: (value, tableMeta, updateValue) => {
          if( value > DateTime.local( ) ){
            return ('Active' );
          }else{
            return( 'Expired' );
          }
        }
      }
    },
    {
      label: 'Open Date',
      name: 'start_date',
      options: {
        filter: false,
        display: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const dt = DateTime.fromISO( value,{ zone: Settings.defaultZoneName } );
          return(<span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>)
        }
      }
    },
    {
      label: 'Close Date',
      name: 'end_date',
      options: {
        filter: false,
        customBodyRender: (value, tableMeta, updateValue) => {
          const dt = DateTime.fromISO( value,{ zone: Settings.defaultZoneName } );
          return(<span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>)
        }
      }
    },
    {
      label: 'Actions',
      name: 'link',
      options: {
        filter: false,
      }
    },
  ]

  const [menuAnchorEl, setMenuAnchorEl] = useState( null );
  const addButton = (
    <React.Fragment>
      <IconButton
        onClick={event=>{
          setMenuAnchorEl( event.currentTarget );
        }}
        aria-label='Add Activity'>
        <AddIcon/>
      </IconButton>
      <Menu
        id='addMenu'
        anchorEl={menuAnchorEl}
        keepMounted
        open={Boolean(menuAnchorEl)}
        onClose={()=>{
          setMenuAnchorEl( null );
        }}>
          {
          newActivityLinks.map((linkData)=>{
            return(
            <MenuItem
              key={linkData.name}
              onClick={(event)=>{
                setMenuAnchorEl( null );
                window.location.href = linkData.link;
              }}>
                {iconForType( linkData.name )}{' New ' + linkData.name}&hellip;

            </MenuItem>

            )
          })}

      </Menu>
    </React.Fragment>
  )
  const activityList =(
          ( courseId != null && courseId > 0) ?
            (
              <MUIDataTable
                title='Activities'
                columns={activityColumns}
                data={courseActivities}
                options={{
                  responsive: 'scrollMaxHeight',
                  filterType: 'checkbox',
                  print: false,
                  download: false,
                  customToolbar: ()=>{
                    return addButton;
                  },
                  onRowClick: (rowData, rowState) =>{
                    const link = courseActivities[ rowState.dataIndex ].link
                    if( null != link ){
                      window.location.href = link
                    }
                  }
                }}
              /> 
            ) : 'You must save the Course to have activities.' )


  return (
    <Paper>
      <Tabs centered value={curTab} onChange={(event, value) => setCurTab(value)}>
        <Tab label="Details" value="details" />
        <Tab value='people' label='People' />
        <Tab value='activities' label='Activities' />
      </Tabs>
      {"details" == curTab ? detailsComponent : null}
      {"people" == curTab ? (
        ('Coming soon!')
      ) : null}
      {"activities" == curTab ? activityList : null }
    </Paper>
  );
}

CourseDataAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
  courseId: PropTypes.number
};
