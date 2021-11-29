import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Paper from "@material-ui/core/Paper";
import { iconForType } from "./ActivityLib";
import {useDispatch} from 'react-redux';
import {startTask, endTask} from './infrastructure/StatusActions';

import MUIDataTable from "mui-datatables";
import axios from "axios";

export default function UserCourseList(props) {
  // const [addUsersPath, setAddUsersPath] = useState("");
  // const [procRegReqPath, setProcRegReqPath] = useState("");
  const dispatch = useDispatch( );

  const getActivities = () => {
    dispatch( startTask() );
    var url = props.retrievalUrl;
    axios.get( url, { } )
      .then(data => {
        console.log(data);
        //MetaData and Infrastructure
        props.activitiesListUpdateFunc(data);
        dispatch( endTask() );
      })
      .catch( error =>{
        console.log( 'error', error );
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
        customBodyRender: value => {
          const output = iconForType(value);
          return output;
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
        title={"Activities"}
        columns={activityColumns}
        data={props.activitiesList}
        options={{
          responsive: "standard",
          filterType: "checkbox",
          selectableRows: "none",
          print: false,
          download: false
        }}
      />
    ) : (
      "The activities are loading"
    );

  return (
    <Paper>
      <WorkingIndicator identifier="activity_list_loading" />
      {activityList}
    </Paper>
  );
}

UserCourseList.propTypes = {
  retrievalUrl: PropTypes.string.isRequired,
  activitiesList: PropTypes.array,
  activitiesListUpdateFunc: PropTypes.func.isRequired,

  addMessagesFunc: PropTypes.func.isRequired
};
