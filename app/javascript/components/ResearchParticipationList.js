import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import Link from '@material-ui/core/Link'
import Paper from "@material-ui/core/Paper";

import { useStatusStore } from './infrastructure/StatusStore';

import MUIDataTable from "mui-datatables";


export default function UserCourseList(props) {
  const [status, statusActions] = useStatusStore( );

  const getCourses = () => {
    statusActions.startTask(  );
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
        props.consentFormListUpdateFunc(data);
        statusActions.endTask();
      });
  };

  useEffect(() => {
    if (null == props.usersList || props.usersList.length < 1) {
      getCourses();
    }
  }, []);

  var consentColumns = [
    {
      label: "Name",
      name: "name",
      options: {
        filter: false
      }
    },
    {
      label: "Consent Form Status",
      name: "id",
      options: {
        filter: true,
        customBodyRender: (value) => {
          const consentForm = props.consentFormList.filter((item)=> {
            return value === item.id;
          })[0]
          // let output: String;
          var output;
          if( consentForm.active ){
            if( Date.now() < Date.parse( consentForm. end_date ) ){
              output = 'Active'
            } else {
              output = 'Inactive (expired)'
            }

          } else {
            output = 'Inactive'
          }
          return (
          <span>
            {output}
          </span>
          )
        }
      }
    },
    {
      label: "Consent Status",
      name: "accepted",
      options: {
        filter: true,
        customBodyRender: (value) => {
          return (
            <span>
              {value ? 'Accepted' : 'Declined'}
            </span>
          )
        }
      }
    },
    {
      label: "Action",
      name: "link",
      options: {
        filter: false,
        customBodyRender: (value) => {
          return (
            <Link href={value}>
              Review/Update
            </Link>
          )
        }
      }
    }
  ];

  const consentFormList =
    null != props.consentFormList ? (
      <MUIDataTable
        title={"Your research participation"}
        columns={consentColumns}
        data={props.consentFormList}
        options={{
          responsive: "standard",
          filterType: "checkbox",
          selectableRows: "none",
          print: false,
          download: false
        }}
      />
    ) : 'The course data is loading';

  return (
    <Paper>
       {consentFormList}
    </Paper>
  );
}

UserCourseList.propTypes = {
  token: PropTypes.string.isRequired,
  retrievalUrl: PropTypes.string.isRequired,
  consentFormList: PropTypes.array,
  consentFormListUpdateFunc: PropTypes.func.isRequired,

  addMessagesFunc: PropTypes.func.isRequired
};