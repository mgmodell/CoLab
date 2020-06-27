import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import Paper from "@material-ui/core/Paper";
import { iconForType } from "./ActivityLib";
import { useStatusStore } from "./infrastructure/StatusStore";

import MUIDataTable from "mui-datatables";

export default function UserCourseList(props) {
  // const [addUsersPath, setAddUsersPath] = useState("");
  // const [procRegReqPath, setProcRegReqPath] = useState("");
  const [status, statusActions] = useStatusStore();

  const getActivities = () => {
    statusActions.startTask();
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
        console.log(data);
        //MetaData and Infrastructure
        props.activitiesListUpdateFunc(data);
        statusActions.endTask();
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
  token: PropTypes.string.isRequired,
  retrievalUrl: PropTypes.string.isRequired,
  activitiesList: PropTypes.array,
  activitiesListUpdateFunc: PropTypes.func.isRequired,

  addMessagesFunc: PropTypes.func.isRequired
};
