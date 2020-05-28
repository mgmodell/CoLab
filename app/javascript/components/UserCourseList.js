import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import LinearProgress from "@material-ui/core/LinearProgress";
import Paper from "@material-ui/core/Paper";

import MUIDataTable from "mui-datatables";

import BingoDataRepresentation from "./BingoBoards/BingoDataRepresentation";

export default function UserCourseList(props) {
  // const [addUsersPath, setAddUsersPath] = useState("");
  // const [procRegReqPath, setProcRegReqPath] = useState("");
  const [] = useState(false);
  const [] = useState("");

  const getCourses = () => {
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
        //MetaData and Infrastructure
        props.coursesListUpdateFunc(data);
        props.setWorking(false);
      });
  };

  useEffect(() => {
    if (null == props.usersList || props.usersList.length < 1) {
      getCourses();
    }
  }, []);

  var courseColumns = [
    {
      label: "Name",
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: "Number",
      name: "number",
      options: {
        filter: false
      }
    },
    {
      label: "Bingo Progress",
      name: "id",
      options: {
        filter: false,
        customBodyRender: (value) => {
          const course = props.coursesList.filter((item)=> {
            return value === item.id;
          })[0]
          console.log( course )
          const data = course.bingo_data;
          return (
          <React.Fragment>
            <BingoDataRepresentation
              height={30}
              width={70}
              value={Number(value)}
              scores={data} />

          </React.Fragment>
          )
        }
      }
    },
    {
      label: "Assessment Progress",
      name: "assessment_performance",
      options: {
        filter: false,
        customBodyRender: (value) => {
          return value + "%";
        }
      }
    },
    {
      label: "Experience Progress",
      name: "experience_performance",
      options: {
        filter: false,
        customBodyRender: (value) => {
          return value + "%";
        }
      }
    }
  ];

  const courseList =
    null != props.coursesList ? (
      <MUIDataTable
        title={'Your course performance'}
        columns={courseColumns}
        data={props.coursesList}
        options={{
          responsive: "scrollMaxHeight",
          filterType: "checkbox",
          selectableRows: "none",
          print: false,
          download: false
        }}
      />
    ) : 'The course data is loading';

  return (
    <Paper>
      {props.working ? <LinearProgress id='waiting' /> : null}
      {courseList}
    </Paper>
  );
}

UserCourseList.propTypes = {
  token: PropTypes.string.isRequired,
  retrievalUrl: PropTypes.string.isRequired,
  coursesList: PropTypes.array,
  coursesListUpdateFunc: PropTypes.func.isRequired,

  addMessagesFunc: PropTypes.func.isRequired,
  working: PropTypes.bool.isRequired,
  setWorking: PropTypes.func.isRequired
};
