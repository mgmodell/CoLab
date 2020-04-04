import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Alert from '@material-ui/lab/Alert'
import IconButton from '@material-ui/core/IconButton';
import LinearProgress from "@material-ui/core/LinearProgress";
import Paper from '@material-ui/core/Paper';
import Tooltip from '@material-ui/core/Tooltip'
import {DateTime} from 'luxon'
import Settings from 'luxon/src/settings.js'
import {
  KeyboardDatePicker,
  MuiPickersUtilsProvider
} from "@material-ui/pickers";
import LuxonUtils from '@date-io/luxon';


import CloudDownloadIcon from '@material-ui/icons/CloudDownload';
import BookIcon from '@material-ui/icons/Book';
import CollectionsBookmarkIcon from '@material-ui/icons/CollectionsBookmark';
import AddIcon from '@material-ui/icons/Add';
import CloseIcon from '@material-ui/icons/Close';

import { useEndpointStore } from "./EndPointStore"
import { useUserStore } from "./UserStore"
import MUIDataTable from "mui-datatables";
import Dialog from "@material-ui/core/Dialog";
import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import { DialogActions, Button, Collapse } from "@material-ui/core";

export default function CourseList(props) {
  const endpointSet = 'course';
  const [endpoints, endpointsActions] = useEndpointStore();
  const [user, userActions] = useUserStore();
  const [copyData, setCopyData] = useState( null );
  const [messages, setMessages] = useState()
  const [showErrors, setShowErrors] = useState( false );

  function PaperComponent(props) {
    return (
        <Paper {...props} />
    );
  }

  const [working, setWorking] = useState(true);
  const columns = 
            [

              {
                label: 'Number',
                name: 'number',
                options: {
                  filter: false,
                  customBodyRender: (value, tableMeta, updateValue) => {
                    return(
                      <span>
                        <BookIcon/>&nbsp;{value}
                      </span>
                    )
                  },
                }
              },
              {
                label: 'Name',
                name: 'name',
                options: {
                  filter: false,
                  display: true
                }
              },
              {
                label: 'School',
                name: 'school_name',
                options: {
                  filter: true,
                  display: true
                }
              },
              {
                label: 'Open Date',
                name: 'start_date',
                options: {
                  filter: false,
                  display: true,
                  customBodyRender: (value, tableMeta, updateValue) => {
                    const dt = DateTime.fromISO( value, { zone: Settings.defaultZoneName } );
                    return(<span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>)
                  }

                }
              },
              {
                label: 'Close Date',
                name: 'end_date',
                options: {
                  filter: false,
                  display: true,
                  customBodyRender: (value, tableMeta, updateValue) => {
                    const dt = DateTime.fromISO( value,{ zone: Settings.defaultZoneName } );
                    return(<span>{dt.toLocaleString(DateTime.DATETIME_MED)}</span>)
                  }

                }
              },
              {
                label: 'Faculty',
                name: 'faculty_count',
                options: {
                  filter: false,
                  display: false
                }
              },
              {
                label: 'Students',
                name: 'student_count',
                options: {
                  filter: false,
                  display: false
                }
              },
              {
                label: 'Projects',
                name: 'project_count',
                options: {
                  filter: false,
                  display: false
                }
              },
              {
                label: 'Experiences',
                name: 'experience_count',
                options: {
                  filter: false,
                  display: false
                }
              },
              {
                label: 'Bingo Games',
                name: 'bingo_game_count',
                options: {
                  filter: false,
                  display: false
                }
              },
              {
                label: 'Actions',
                name: 'id',
                options: {
                  display: true,
                  filter: false,
                  customBodyRender: (value, tableMeta, updateValue) => {
                    const scoresUrl = endpoints.endpoints[endpointSet].scoresUrl + value + '.csv'
                    const copyUrl = endpoints.endpoints[endpointSet].courseCopyUrl + value + '.json'
                    return(
                      <React.Fragment>
                        <Tooltip title="Download Scores to CSV" aria-label="Download">
                          <IconButton
                            id={'csv-' + value }
                            onClick={event=>{
                              window.location.href=scoresUrl;
                              event.preventDefault()
                            }}
                            aria-label='Download scores as CSV'>
                              <CloudDownloadIcon/>
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Create a copy based on this course" aria-label="Copy">
                          <IconButton
                            id={'copy-' + value }
                            onClick={event=>{
                              const element = courses.filter((element)=>{return value == element.id })[0]
                              setCopyData( {
                                id: value,
                                startDate: DateTime.fromISO( element.start_date ),
                                copyUrl: copyUrl
                              } );
                            }}
                            aria-label='Make a Copy'>
                              <CollectionsBookmarkIcon/>
                          </IconButton>
                        </Tooltip>
                      </React.Fragment>
                    )
                  }
                }
              },
            ]

  const [courses, setCourses] = useState( [ ] );
  const [newStartDate, setNewStartDate] = useState( DateTime.local().toISO() );
  const copyDialog = (
                       <Dialog
                         open={null != copyData}
                         PaperComponent={PaperComponent}
                         onClose={(event,reason)=>{
                           setNewStartDate( DateTime.local().toISO( ) )
                           setNewStartDate( null )
                           setCopyData( null )
                         }}
                         >
                           {null != copyData ? (
                             <React.Fragment>

                              <DialogTitle>Create a Copy</DialogTitle>
                              <DialogContent>
                                {working ? <LinearProgress/> : null }
                                <DialogContentText>
                                  This course started on {copyData.startDate.toLocaleString(DateTime.DATE_SHORT)}.
                                  When would you like for the new copy to begin? Everything will be shifted accordingly.
                                  <br/>

                                </DialogContentText>
                                 <MuiPickersUtilsProvider utils={LuxonUtils}>
                                   <KeyboardDatePicker
                                     variant='inline'
                                     autoOk={true}
                                     format="MM/dd/yyyy"
                                     margin='normal'
                                     id='newCourseStartDate'
                                     label="New course start date?"
                                     value={newStartDate}
                                     onChange={setNewStartDate}
                                   />
                                  </MuiPickersUtilsProvider>
                              </DialogContent>
                              <DialogActions>
                                <Button disabled={working} onClick={(event)=>{
                                    setNewStartDate( DateTime.local().toISO( ) );
                                    setNewStartDate( null );
                                    setCopyData(null)
                                  }}
                                  >
                                  Cancel
                                </Button>
                                <Button disabled={working} onClick={(event)=>{
                                  setWorking( true );
                                  console.log( newStartDate );
                                  fetch( copyData.copyUrl ,{
                                    method: 'POST',
                                    credentials: 'include',
                                    headers: {
                                      'Content-Type': 'application/json',
                                      Accepts: 'application/json',
                                      'X-CSRF-Token': props.token
                                    },
                                    body: JSON.stringify({
                                      start_date: newStartDate
                                    })
                                  })
                                  .then(response=>{
                                    if( response.ok ){
                                      return response.json()
                                    }else{
                                      console.log( 'Error' )
                                    }
                                  })
                                  .then(data =>{
                                      setMessages( data.messages )
                                      getCourses();
                                      setNewStartDate( DateTime.local().toISO( ) )
                                      setCopyData( null );
                                      setWorking( false );
                                  })
                                }}
                                >
                                  Make a Copy
                                </Button>
                              </DialogActions> 
                             </React.Fragment> ) : <DialogContent></DialogContent> }
                       </Dialog> )


  const getCourses = () => {
    var url = endpoints.endpoints[endpointSet].baseUrl + '.json';

    fetch(url, {
      method: 'GET',
      credentials: 'include',
      cache: 'no-cache',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': props.token
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
        //Process the data
        setCourses( data )
        setWorking( false );
      });
  };
  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != 'loaded') {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  useEffect(() =>{
    if (endpoints.endpointStatus[endpointSet] == 'loaded') {
      getCourses();
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

  const muiDatTab = (
    <MUIDataTable
      title='Courses'
      data={courses}
      columns={columns}
      options={{
        responsive: 'scrollMaxHeight',
        filterType:'checkbox',
        print: false,
        download: false,
        customToolbar: ()=>(
          <Tooltip
            title='New Course'>
            <IconButton
              id='new_course'
              onClick={event=>{
                window.location.href = endpoints.endpoints[endpointSet].courseCreateUrl;
              }}
              aria-label='New Course'>
              <AddIcon/>
            </IconButton>
          </Tooltip>
        ),
        onCellClick: (colData, cellMeta) =>{
          if( 'Actions' != columns[ cellMeta.colIndex ].label ){
            const link = endpoints.endpoints[endpointSet].baseUrl + '/' + courses[ cellMeta.dataIndex ].id
            if( null != link ){
              window.location.href = link
            }

          }

        },
        selectableRows: 'none'
      }}
      />
  )

  return (
    <React.Fragment>
      <Collapse in={showErrors}>
        <Alert action={
          <IconButton
            aria-label="close"
            color="inherit"
            size='small'
            onClick={() => {
              setShowErrors(false );
            }}
            >
              <CloseIcon fontSize='inherit'/>
            </IconButton>
        }
        >
          {null != messages ? messages.main : null }
        </Alert>
      </Collapse>
      {working ? <LinearProgress/> : null }
      <div style={{ maxWidth: '100%' }}>
        {copyDialog}
        {muiDatTab}
      </div>
    </React.Fragment>
  );
}

CourseList.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired,
};
