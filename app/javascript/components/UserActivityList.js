import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import Paper from "@material-ui/core/Paper";
import { iconForType } from './ActivityLib'

import MUIDataTable from "mui-datatables";

import BingoDataRepresentation from "./BingoDataRepresentation";

export default function UserCourseList(props) {
  // const [addUsersPath, setAddUsersPath] = useState("");
  // const [procRegReqPath, setProcRegReqPath] = useState("");
  const [] = useState(false);
  const [] = useState("");

  const getActivities = () => {
    props.setWorking( true );
    var url = props.retrievalUrl;
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
        console.log( data );
        //MetaData and Infrastructure
        props.activitiesListUpdateFunc(data);
        props.setWorking(false);
      });
  };

  useEffect(() => {
    if (null == props.usersList || props.usersList.length < 1) {
      getActivities();
    }
  }, []);

  var activityColumns = [
    {
      label: "Name",
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: "Type",
      name: "type",
      options: {
        filter: false,
        customBodyRender: (value) => {
          const course = props.activitiesList.filter((item)=> {
            return value === item.id;
          })[0]
          const output = iconForType( value )
          return output
        }
      }
    },
    {
      label: "Course Name",
      name: "course_name",
      options: {
        filter: false
      }
    },
    {
      label: "Course Number",
      name: "course_number",
      options: {
        filter: false
      }
    }
  ];

  const activityList =
    null != props.activitiesList ? (
      <MUIDataTable
        title={'Activities'}
        columns={activityColumns}
        data={props.activitiesList}
        options={{
          responsive: "scrollMaxHeight",
          filterType: "checkbox",
          selectableRows: "none",
          print: false,
          download: false
        }}
      />
    ) : 'The activities are loading' ;

  return (
    <Paper>
      {props.working ? <LinearProgress id='waiting' /> : null}
      {activityList}
    </Paper>
  );
}

UserCourseList.propTypes = {
  token: PropTypes.string.isRequired,
  retrievalUrl: PropTypes.string.isRequired,
  activitiesList: PropTypes.array,
  activitiesListUpdateFunc: PropTypes.func.isRequired,

  addMessagesFunc: PropTypes.func.isRequired,
  working: PropTypes.bool.isRequired,
  setWorking: PropTypes.func.isRequired
};
